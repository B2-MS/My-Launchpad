import SwiftUI
import Carbon

/// Shared window settings accessible across the app
class WindowSettings: ObservableObject {
    static let shared = WindowSettings()
    @Published var opacity: Double = 0.95
}

/// Global hotkey manager using Carbon APIs with system event target
class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotkeyRef: EventHotKeyRef?
    
    // Store callback to prevent deallocation
    private var hotKeyHandler: EventHandlerUPP?
    private var eventHandlerRef: EventHandlerRef?
    
    func registerHotkey() {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4D414C43) // "MALC"
        hotKeyID.id = 1
        
        // Control + Option + Space
        let modifiers: UInt32 = UInt32(controlKey | optionKey)
        let keyCode: UInt32 = 49 // Space
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        // Create the handler
        hotKeyHandler = { (nextHandler, event, userData) -> OSStatus in
            var hkID = EventHotKeyID()
            GetEventParameter(event,
                            EventParamName(kEventParamDirectObject),
                            EventParamType(typeEventHotKeyID),
                            nil, MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            
            if hkID.id == 1 {
                DispatchQueue.main.async {
                    HotkeyManager.shared.toggleWindow()
                }
            }
            return noErr
        }
        
        // Install to EVENT DISPATCHER target (system-wide)
        var status = InstallEventHandler(
            GetEventDispatcherTarget(),
            hotKeyHandler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
        
        if status != noErr {
            print("Failed to install event handler: \(status)")
            return
        }
        
        // Register the hotkey to EVENT DISPATCHER (system-wide)
        status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotkeyRef
        )
        
        if status != noErr {
            print("Failed to register hotkey: \(status)")
        } else {
            print("Global hotkey registered: Control + Option + Space")
        }
    }
    
    func toggleWindow() {
        if let window = NSApp.windows.first(where: { $0.canBecomeKey }), window.isVisible, NSApp.isActive {
            NSApp.hide(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
                // Make window appear on all spaces/desktops
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.makeKeyAndOrderFront(nil)
                window.center()
            }
        }
    }
    
    func unregisterHotkey() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }
}

@main
struct MyAppLauncherApp: App {
    @StateObject private var windowSettings = WindowSettings.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(TransparentWindowBackground(opacity: windowSettings.opacity))
                .background(WindowAccessor())
                .environmentObject(windowSettings)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) { }
            
            CommandMenu("Groups") {
                Button("New Group...") {
                    NotificationCenter.default.post(name: .createNewGroup, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .help) {
                Button("My App Launcher Help") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        // Menu bar is now handled by AppDelegate with custom NSStatusItem
    }
}

/// App delegate to handle global hotkey registration
class AppDelegate: NSObject, NSApplicationDelegate {
    private var keepAliveTimer: Timer?
    private var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as accessory app (no dock icon, stays running)
        NSApp.setActivationPolicy(.accessory)
        
        HotkeyManager.shared.registerHotkey()
        
        // Setup custom status bar item with click-to-show behavior
        setupStatusBarItem()
        
        // Keep the run loop active for hotkey processing
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // This keeps the run loop active to process Carbon events
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
        
        // Register for app deactivation (clicking outside)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
        
        // Show the window on launch (check hideOnLaunch setting)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let data = DataManager.shared.load(), data.hideOnLaunch == true {
                // Don't show window on launch, but still set collection behavior
                if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
                    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                }
                return
            }
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
                // Make window appear on all spaces/desktops
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.makeKeyAndOrderFront(nil)
                window.center()
            }
        }
    }
    
    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "square.grid.2x2.fill", accessibilityDescription: "App Launcher")
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }
        
        // Create menu for right-click
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Launcher (⌃⌥Space)", action: #selector(showLauncher), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = nil // Don't set menu directly - we'll show it conditionally
    }
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        // Right-click shows menu
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Show Launcher (⌃⌥Space)", action: #selector(showLauncher), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
            
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil
        } else {
            // Left-click toggles window visibility
            toggleLauncher()
        }
    }
    
    @objc private func toggleLauncher() {
        if let window = NSApp.windows.first(where: { $0.canBecomeKey }), window.isVisible, NSApp.isActive {
            // Window is visible and app is active - hide it
            NSApp.hide(nil)
        } else {
            // Window is hidden - show it
            showLauncher()
        }
    }
    
    @objc private func showLauncher() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
            // Make window appear on all spaces/desktops
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.makeKeyAndOrderFront(nil)
            window.center()
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    @objc func applicationDidResignActive(_ notification: Notification) {
        // Check if hideOnFocusLost is enabled
        if let data = DataManager.shared.load(), data.hideOnFocusLost == true {
            // Hide all windows when focus is lost
            for window in NSApp.windows {
                window.orderOut(nil)
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        keepAliveTimer?.invalidate()
        HotkeyManager.shared.unregisterHotkey()
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
            // Make window appear on all spaces/desktops
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.makeKeyAndOrderFront(nil)
            window.center()
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in background
    }
}

/// Intercepts window close to hide instead of close
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.delegate = context.coordinator
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, NSWindowDelegate {
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            // Hide instead of close
            sender.orderOut(nil)
            return false
        }
    }
}

/// Makes the window background transparent
struct TransparentWindowBackground: NSViewRepresentable {
    let opacity: Double
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isOpaque = false
                window.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(opacity)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.isOpaque = false
                window.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(opacity)
            }
        }
    }
}

// Notification names for app-wide events
extension Notification.Name {
    static let createNewGroup = Notification.Name("createNewGroup")
}
