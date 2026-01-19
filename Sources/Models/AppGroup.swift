import Foundation

/// Represents a group of applications
struct AppGroup: Identifiable, Codable {
    let id: UUID
    var name: String
    var appIds: [UUID]
    var isExpanded: Bool
    var order: Int
    var positionX: Double
    var positionY: Double
    var width: Double
    var height: Double
    
    init(id: UUID = UUID(), name: String, appIds: [UUID] = [], isExpanded: Bool = true, order: Int = 0, positionX: Double = 50, positionY: Double = 50, width: Double = 280, height: Double = 200) {
        self.id = id
        self.name = name
        self.appIds = appIds
        self.isExpanded = isExpanded
        self.order = order
        self.positionX = positionX
        self.positionY = positionY
        self.width = width
        self.height = height
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, appIds, isExpanded, order, positionX, positionY, width, height
    }
}

/// Data structure to persist all launcher data
struct LauncherData: Codable {
    var groups: [AppGroup]
    var ungroupedAppIds: [UUID]
    var allApps: [AppItem]
    
    init(groups: [AppGroup] = [], ungroupedAppIds: [UUID] = [], allApps: [AppItem] = []) {
        self.groups = groups
        self.ungroupedAppIds = ungroupedAppIds
        self.allApps = allApps
    }
}
