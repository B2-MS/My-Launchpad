import Foundation
import AppKit

/// Scans the Applications folder for installed applications
class AppScanner {
    
    /// Standard paths to scan for applications
    static let applicationPaths = [
        "/Applications",
        "/System/Applications",
        "/System/Applications/Utilities",
        NSHomeDirectory() + "/Applications"
    ]
    
    /// Scan all application directories and return found apps
    static func scanApplications() -> [AppItem] {
        var apps: [AppItem] = []
        let fileManager = FileManager.default
        
        for basePath in applicationPaths {
            guard fileManager.fileExists(atPath: basePath) else { continue }
            
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: basePath)
                for item in contents {
                    let fullPath = (basePath as NSString).appendingPathComponent(item)
                    
                    // Check if it's an application bundle
                    if item.hasSuffix(".app") {
                        if let appItem = createAppItem(from: fullPath) {
                            apps.append(appItem)
                        }
                    }
                }
            } catch {
                print("Error scanning \(basePath): \(error.localizedDescription)")
            }
        }
        
        // Sort apps alphabetically by name
        return apps.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    /// Create an AppItem from an application path
    private static func createAppItem(from path: String) -> AppItem? {
        let url = URL(fileURLWithPath: path)
        
        // Get app name (remove .app extension)
        var appName = url.deletingPathExtension().lastPathComponent
        
        // Try to get display name from bundle
        if let bundle = Bundle(path: path),
           let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            appName = displayName
        } else if let bundle = Bundle(path: path),
                  let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
            appName = bundleName
        }
        
        // Get bundle identifier
        let bundleIdentifier = Bundle(path: path)?.bundleIdentifier
        
        return AppItem(
            name: appName,
            path: path,
            bundleIdentifier: bundleIdentifier
        )
    }
    
    /// Check if an app still exists at its path
    static func appExists(_ app: AppItem) -> Bool {
        return FileManager.default.fileExists(atPath: app.path)
    }
}
