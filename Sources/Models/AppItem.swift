import Foundation
import AppKit

/// Represents a single application that can be launched
struct AppItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let path: String
    let bundleIdentifier: String?
    
    init(id: UUID = UUID(), name: String, path: String, bundleIdentifier: String? = nil) {
        self.id = id
        self.name = name
        self.path = path
        self.bundleIdentifier = bundleIdentifier
    }
    
    /// Get the app icon from the application bundle
    func getIcon() -> NSImage {
        let workspace = NSWorkspace.shared
        return workspace.icon(forFile: path)
    }
    
    /// Launch the application
    func launch() {
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { _, error in
            if let error = error {
                print("Failed to launch \(name): \(error.localizedDescription)")
            }
        }
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, path, bundleIdentifier
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.id == rhs.id
    }
}
