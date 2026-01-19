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
        
        // Menu bar icon
        MenuBarExtra("App Launcher", systemImage: "square.grid.2x2.fill") {
            Button("Show Launcher (⌃⌥Space)") {
                showMainWindow()
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
    
    private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
            window.makeKeyAndOrderFront(nil)
            window.center()
        }
    }
}

/// App delegate to handle global hotkey registration
class AppDelegate: NSObject, NSApplicationDelegate {
    private var keepAliveTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as accessory app (no dock icon, stays running)
        NSApp.setActivationPolicy(.accessory)
        
        HotkeyManager.shared.registerHotkey()
        
        // Keep the run loop active for hotkey processing
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // This keeps the run loop active to process Carbon events
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
        
        // Show the window on launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
                window.makeKeyAndOrderFront(nil)
                window.center()
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        keepAliveTimer?.invalidate()
        HotkeyManager.shared.unregisterHotkey()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
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
