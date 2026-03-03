import Foundation

/// Represents a tile in the main launcher grid - either a group or a standalone app
enum LauncherTile: Codable, Hashable, Identifiable {
    case group(UUID)
    case standaloneApp(UUID)
    
    var id: String {
        switch self {
        case .group(let uuid): return "group:\(uuid.uuidString)"
        case .standaloneApp(let uuid): return "app:\(uuid.uuidString)"
        }
    }
    
    var uuid: UUID {
        switch self {
        case .group(let uuid): return uuid
        case .standaloneApp(let uuid): return uuid
        }
    }
    
    var isGroup: Bool {
        if case .group = self { return true }
        return false
    }
    
    var isStandaloneApp: Bool {
        if case .standaloneApp = self { return true }
        return false
    }
}

/// Represents the display size of a group tile
enum GroupTileSize: String, Codable, CaseIterable {
    case standard = "standard"    // 1x1 standard tile (2x2 app preview)
    case large = "large"          // 2x1 landscape (4x2 app preview) - 2 tiles wide
    case extraLarge = "extraLarge" // 2x2 (4x4 app preview) - 2 tiles wide, 2 tiles tall
    
    /// Columns of app icons inside the group
    var columns: Int {
        switch self {
        case .standard: return 2
        case .large: return 4
        case .extraLarge: return 4
        }
    }
    
    /// Rows of app icons inside the group
    var rows: Int {
        switch self {
        case .standard: return 2
        case .large: return 2
        case .extraLarge: return 4
        }
    }
    
    var appCount: Int {
        columns * rows
    }
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .large: return "Large (2×1)"
        case .extraLarge: return "Extra Large (2×2)"
        }
    }
    
    /// Width multiplier for the tile (in terms of standard tiles)
    var widthMultiplier: CGFloat {
        switch self {
        case .standard: return 1.0
        case .large: return 2.0
        case .extraLarge: return 2.0
        }
    }
    
    /// Height multiplier for the tile (in terms of standard tiles)
    var heightMultiplier: CGFloat {
        switch self {
        case .standard: return 1.0
        case .large: return 1.0
        case .extraLarge: return 2.0
        }
    }
    
    /// How many standard tile slots this size occupies horizontally
    var gridSpanWidth: Int {
        switch self {
        case .standard: return 1
        case .large: return 2
        case .extraLarge: return 2
        }
    }
    
    /// How many standard tile slots this size occupies vertically
    var gridSpanHeight: Int {
        switch self {
        case .standard: return 1
        case .large: return 1
        case .extraLarge: return 2
        }
    }
    
    /// Options available for resize menu (excludes standard which is the default)
    static var resizeOptions: [GroupTileSize] {
        [.large, .extraLarge]
    }
}

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
    var tileSize: GroupTileSize
    
    /// Returns the actual app IDs (excluding voids)
    var actualAppIds: [UUID] {
        appIds.filter { $0 != AppGroup.voidId }
    }
    
    /// Check if a UUID is a void
    static func isVoid(_ id: UUID) -> Bool {
        return id == voidId
    }
    
    init(id: UUID = UUID(), name: String, appIds: [UUID] = [], isExpanded: Bool = true, order: Int = 0, positionX: Double = 50, positionY: Double = 50, width: Double = 280, height: Double = 200, tileSize: GroupTileSize = .standard) {
        self.id = id
        self.name = name
        self.appIds = appIds
        self.isExpanded = isExpanded
        self.order = order
        self.positionX = positionX
        self.positionY = positionY
        self.width = width
        self.height = height
        self.tileSize = tileSize
    }
    
    // Codable conformance with migration support
    enum CodingKeys: String, CodingKey {
        case id, name, appIds, isExpanded, order, positionX, positionY, width, height, tileSize
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        appIds = try container.decode([UUID].self, forKey: .appIds)
        isExpanded = try container.decode(Bool.self, forKey: .isExpanded)
        order = try container.decode(Int.self, forKey: .order)
        positionX = try container.decode(Double.self, forKey: .positionX)
        positionY = try container.decode(Double.self, forKey: .positionY)
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
        // Migration: default to standard if tileSize not present
        tileSize = try container.decodeIfPresent(GroupTileSize.self, forKey: .tileSize) ?? .standard
    }
}

/// Data structure to persist all launcher data
struct LauncherData: Codable {
    var groups: [AppGroup]
    var ungroupedAppIds: [UUID]
    var allApps: [AppItem]
    var launcherTiles: [LauncherTile]?  // Ordered list of groups and standalone apps
    var groupTileScale: Double?
    var hideOnLaunch: Bool?
    var hideOnFocusLost: Bool?
    var windowWidth: Double?
    var windowHeight: Double?
    var backupToICloud: Bool?
    var backupToOneDrive: Bool?
    
    init(groups: [AppGroup] = [], ungroupedAppIds: [UUID] = [], allApps: [AppItem] = [], launcherTiles: [LauncherTile]? = nil, groupTileScale: Double? = nil, hideOnLaunch: Bool? = nil, hideOnFocusLost: Bool? = nil, windowWidth: Double? = nil, windowHeight: Double? = nil, backupToICloud: Bool? = nil, backupToOneDrive: Bool? = nil) {
        self.groups = groups
        self.ungroupedAppIds = ungroupedAppIds
        self.allApps = allApps
        self.launcherTiles = launcherTiles
        self.groupTileScale = groupTileScale
        self.hideOnLaunch = hideOnLaunch
        self.hideOnFocusLost = hideOnFocusLost
        self.windowWidth = windowWidth
        self.windowHeight = windowHeight
        self.backupToICloud = backupToICloud
        self.backupToOneDrive = backupToOneDrive
    }
}
