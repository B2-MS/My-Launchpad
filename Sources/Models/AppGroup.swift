import Foundation

/// Represents a group of applications
struct AppGroup: Identifiable, Codable {
    /// Special UUID that represents an empty "void" slot in the grid
    static let voidId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    let id: UUID
    var name: String
    var appIds: [UUID]  // Can contain voidId for empty slots
    var isExpanded: Bool
    var order: Int
    var positionX: Double
    var positionY: Double
    var width: Double
    var height: Double
    
    /// Returns the actual app IDs (excluding voids)
    var actualAppIds: [UUID] {
        appIds.filter { $0 != AppGroup.voidId }
    }
    
    /// Check if a UUID is a void
    static func isVoid(_ id: UUID) -> Bool {
        return id == voidId
    }
    
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
    var groupTileScale: Double?
    
    init(groups: [AppGroup] = [], ungroupedAppIds: [UUID] = [], allApps: [AppItem] = [], groupTileScale: Double? = nil) {
        self.groups = groups
        self.ungroupedAppIds = ungroupedAppIds
        self.allApps = allApps
        self.groupTileScale = groupTileScale
    }
}
