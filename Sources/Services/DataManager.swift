import Foundation
import AppKit
import UniformTypeIdentifiers

/// Manages persistence of launcher data
class DataManager {
    
    static let shared = DataManager()
    
    private let dataFileName = "MyAppLauncherData.json"
    
    private var dataFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("My App Launcher", isDirectory: true)
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        
        return appFolder.appendingPathComponent(dataFileName)
    }
    
    /// Save launcher data to disk
    func save(_ data: LauncherData) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: dataFileURL)
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
        savePanel.nameFieldStringValue = "My App Launcher Settings.json"
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
}
