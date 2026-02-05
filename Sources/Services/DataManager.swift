import Foundation
import AppKit
import UniformTypeIdentifiers

/// Manages persistence of launcher data
class DataManager {
    
    static let shared = DataManager()
    
    private let dataFileName = "MyLaunchpadData.json"
    private let backupFileName = "My Launchpad Backup.json"
    
    private var dataFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("My Launchpad", isDirectory: true)
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        
        return appFolder.appendingPathComponent(dataFileName)
    }
    
    /// iCloud Drive backup location
    var iCloudBackupURL: URL? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let iCloudPath = homeDir.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs/My Launchpad")
        
        // Check if iCloud Drive exists
        let iCloudDrive = homeDir.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
        guard FileManager.default.fileExists(atPath: iCloudDrive.path) else {
            return nil
        }
        
        // Create My Launchpad folder if needed
        try? FileManager.default.createDirectory(at: iCloudPath, withIntermediateDirectories: true)
        
        return iCloudPath.appendingPathComponent(backupFileName)
    }
    
    /// OneDrive backup location
    var oneDriveBackupURL: URL? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        
        // Check common OneDrive locations
        let possiblePaths = [
            homeDir.appendingPathComponent("Library/CloudStorage/OneDrive-Personal/My Launchpad"),
            homeDir.appendingPathComponent("Library/CloudStorage/OneDrive/My Launchpad"),
            homeDir.appendingPathComponent("OneDrive/My Launchpad")
        ]
        
        for basePath in possiblePaths {
            let parentPath = basePath.deletingLastPathComponent()
            if FileManager.default.fileExists(atPath: parentPath.path) {
                // Create My Launchpad folder if needed
                try? FileManager.default.createDirectory(at: basePath, withIntermediateDirectories: true)
                return basePath.appendingPathComponent(backupFileName)
            }
        }
        
        return nil
    }
    
    /// Check if iCloud Drive is available
    var isICloudAvailable: Bool {
        iCloudBackupURL != nil
    }
    
    /// Check if OneDrive is available
    var isOneDriveAvailable: Bool {
        oneDriveBackupURL != nil
    }
    
    /// Save launcher data to disk and sync to cloud if enabled
    func save(_ data: LauncherData) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: dataFileURL)
            
            // Sync to cloud backups if enabled
            if data.backupToICloud == true, let iCloudURL = iCloudBackupURL {
                try? jsonData.write(to: iCloudURL)
                print("✅ Backed up to iCloud: \(iCloudURL.path)")
            }
            
            if data.backupToOneDrive == true, let oneDriveURL = oneDriveBackupURL {
                try? jsonData.write(to: oneDriveURL)
                print("✅ Backed up to OneDrive: \(oneDriveURL.path)")
            }
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    
    /// Load launcher data from disk
    func load() -> LauncherData? {
        guard FileManager.default.fileExists(atPath: dataFileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: dataFileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(LauncherData.self, from: data)
        } catch {
            print("Failed to load data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Delete all saved data
    func reset() {
        try? FileManager.default.removeItem(at: dataFileURL)
    }
    
    /// Export data to a user-selected file
    func exportData(_ data: LauncherData) -> Bool {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "My Launchpad Settings.json"
        savePanel.title = "Export Settings"
        savePanel.message = "Choose where to save your launcher settings"
        
        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            return false
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url)
            return true
        } catch {
            print("Failed to export data: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Import data from a user-selected file
    func importData() -> LauncherData? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Import Settings"
        openPanel.message = "Select a launcher settings file to import"
        
        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(LauncherData.self, from: data)
        } catch {
            print("Failed to import data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Cloud backup info for display
    struct CloudBackupInfo {
        let source: String  // "iCloud" or "OneDrive"
        let url: URL
        let data: LauncherData
        let modificationDate: Date
        let groupCount: Int
    }
    
    /// Check for available cloud backups
    func discoverCloudBackups() -> [CloudBackupInfo] {
        var backups: [CloudBackupInfo] = []
        let decoder = JSONDecoder()
        let fileManager = FileManager.default
        
        // Check iCloud
        if let iCloudURL = iCloudBackupURL, fileManager.fileExists(atPath: iCloudURL.path) {
            if let data = try? Data(contentsOf: iCloudURL),
               let launcherData = try? decoder.decode(LauncherData.self, from: data),
               let attrs = try? fileManager.attributesOfItem(atPath: iCloudURL.path),
               let modDate = attrs[.modificationDate] as? Date {
                backups.append(CloudBackupInfo(
                    source: "iCloud",
                    url: iCloudURL,
                    data: launcherData,
                    modificationDate: modDate,
                    groupCount: launcherData.groups.count
                ))
            }
        }
        
        // Check OneDrive
        if let oneDriveURL = oneDriveBackupURL, fileManager.fileExists(atPath: oneDriveURL.path) {
            if let data = try? Data(contentsOf: oneDriveURL),
               let launcherData = try? decoder.decode(LauncherData.self, from: data),
               let attrs = try? fileManager.attributesOfItem(atPath: oneDriveURL.path),
               let modDate = attrs[.modificationDate] as? Date {
                backups.append(CloudBackupInfo(
                    source: "OneDrive",
                    url: oneDriveURL,
                    data: launcherData,
                    modificationDate: modDate,
                    groupCount: launcherData.groups.count
                ))
            }
        }
        
        return backups
    }
    
    /// Load data from a specific cloud backup
    func loadFromCloudBackup(_ backup: CloudBackupInfo) -> LauncherData? {
        return backup.data
    }
    
    /// Compare local data with cloud backup to detect differences
    func hasSignificantDifferences(local: LauncherData?, cloud: LauncherData) -> Bool {
        guard let local = local else {
            // No local data, cloud has data - significant difference
            return cloud.groups.count > 0
        }
        
        // Compare group counts
        if local.groups.count != cloud.groups.count {
            return true
        }
        
        // Compare group names
        let localGroupNames = Set(local.groups.map { $0.name })
        let cloudGroupNames = Set(cloud.groups.map { $0.name })
        if localGroupNames != cloudGroupNames {
            return true
        }
        
        return false
    }
}
