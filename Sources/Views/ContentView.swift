import SwiftUI
import UniformTypeIdentifiers

/// Main content view for the app launcher - Grid-based with expandable groups
struct ContentView: View {
    @StateObject private var viewModel = LauncherViewModel()
    @EnvironmentObject var windowSettings: WindowSettings
    @State private var showingNewGroupSheet = false
    @State private var newGroupName = ""
    @State private var appForNewGroup: AppItem? = nil
    @State private var draggedAppId: UUID? = nil
    @State private var dropTargetGroupId: UUID? = nil
    @State private var groupInsertIndex: Int? = nil
    @State private var tileInsertIndex: Int? = nil
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var tilesContainerWidth: CGFloat = 600
    @State private var gridContentHeight: CGFloat = 200
    
    private var standardTileWidth: CGFloat {
        120 * viewModel.groupTileScale
    }
    
    private var standardTileHeight: CGFloat {
        135 * viewModel.groupTileScale
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 130), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            mainContent
            expandedGroupOverlay
        }
        .animation(.spring(response: 0.3), value: viewModel.expandedGroupId)
        .frame(minWidth: 600, minHeight: 450)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingNewGroupSheet) {
            newGroupSheet
        }
        .sheet(isPresented: $viewModel.showCloudBackupPrompt) {
            cloudBackupPromptSheet
        }
        .onTapGesture {
            // Close the system color panel when clicking outside
            NSColorPanel.shared.close()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didHideNotification)) { _ in
            viewModel.searchText = ""
            viewModel.showSettings = false
            viewModel.expandedGroupId = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            viewModel.searchText = ""
            viewModel.showSettings = false
            viewModel.expandedGroupId = nil
        }
    }
    
    // MARK: - Cloud Backup Prompt
    
    private var cloudBackupPromptSheet: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Cloud Settings Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Settings were found in your cloud storage that differ from your local settings.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.availableCloudBackups, id: \.source) { backup in
                    HStack {
                        Image(systemName: backup.source == "iCloud" ? "icloud.fill" : "cloud.fill")
                            .foregroundColor(backup.source == "iCloud" ? .blue : .cyan)
                        
                        VStack(alignment: .leading) {
                            Text(backup.source)
                                .fontWeight(.medium)
                            Text("\(backup.groupCount) groups • \(formatDate(backup.modificationDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Use These") {
                            viewModel.importFromCloudBackup(backup)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal)
            
            Button("Keep Local Settings") {
                viewModel.dismissCloudBackupPrompt()
            }
            .foregroundColor(.secondary)
        }
        .padding(30)
        .frame(width: 400)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.showSettings {
                        settingsSection
                    }
                    
                    if viewModel.isEditMode {
                        editModeToolbar
                    }
                    
                    if !viewModel.groups.isEmpty {
                        groupsSection
                    }
                    
                    appsSection
                        .id("appsSection")
                }
                .padding(.vertical, 16)
            }
            .onAppear {
                scrollProxy = proxy
            }
        }
        .background(
            ZStack {
                // Color tint overlay only - no opaque background
                LinearGradient(
                    colors: [
                        viewModel.groupHeaderColor.opacity(0.05),
                        Color.purple.opacity(0.02),
                        Color.blue.opacity(0.01)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle grid pattern
                gridBackground.opacity(viewModel.backgroundOpacity * 0.1)
            }
        )
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            settingsHeader
            settingsControls
        }
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Glass panel with strong blur
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thickMaterial)
                
                // Gradient color wash
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.12),
                                Color.purple.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Bright highlight edge
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
        .padding(.horizontal, 16)
    }
    
    private var settingsHeader: some View {
        HStack {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.secondary)
            Text("Settings")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: { viewModel.showSettings = false }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
    
    private var settingsControls: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Color")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ColorPicker("", selection: $viewModel.groupHeaderColor, supportsOpacity: false)
                    .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Size")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    tileSizeButton("S", scale: 0.85)
                    tileSizeButton("M", scale: 1.1)
                    tileSizeButton("L", scale: 1.4)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Save my settings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Button(action: {
                        _ = viewModel.exportSettings()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.2))
                        )
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                    .help("Export all groups and settings to a file")
                    
                    Button(action: {
                        _ = viewModel.importSettings()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.2))
                        )
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                    .help("Import groups and settings from a file")
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Behavior")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Toggle("Launch at login", isOn: Binding(
                    get: { viewModel.launchAtLogin },
                    set: { viewModel.launchAtLogin = $0 }
                ))
                    .toggleStyle(.checkbox)
                    .font(.system(size: 12))
                    .help("Automatically start My Launchpad when you log in")
                
                Toggle("Hide on launch", isOn: $viewModel.hideOnLaunch)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 12))
                    .onChange(of: viewModel.hideOnLaunch) { _ in
                        viewModel.saveData()
                    }
                    .help("Hide the launcher when an app is launched")
                
                Toggle("Hide on focus lost", isOn: $viewModel.hideOnFocusLost)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 12))
                    .onChange(of: viewModel.hideOnFocusLost) { _ in
                        viewModel.saveData()
                    }
                    .help("Hide the launcher when clicking outside")
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Cloud Backup")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Toggle("iCloud Drive", isOn: $viewModel.backupToICloud)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 12))
                    .disabled(!viewModel.isICloudAvailable)
                    .onChange(of: viewModel.backupToICloud) { _ in
                        viewModel.saveData()
                    }
                    .help(viewModel.isICloudAvailable ? "Automatically backup settings to iCloud Drive" : "iCloud Drive not available")
                
                Toggle("OneDrive", isOn: $viewModel.backupToOneDrive)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 12))
                    .disabled(!viewModel.isOneDriveAvailable)
                    .onChange(of: viewModel.backupToOneDrive) { _ in
                        viewModel.saveData()
                    }
                    .help(viewModel.isOneDriveAvailable ? "Automatically backup settings to OneDrive" : "OneDrive not available")
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
    
    private func tileSizeButton(_ label: String, scale: Double) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.groupTileScale = scale
                viewModel.saveData()
            }
        }) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 36, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(viewModel.groupTileScale == scale ? viewModel.groupHeaderColor : Color.secondary.opacity(0.2))
                )
                .foregroundColor(viewModel.groupTileScale == scale ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    /// Subtle grid background showing snap positions
    private var gridBackground: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let gridSize: CGFloat = 96 // Matches grid item size (80) + spacing (16)
                let dotRadius: CGFloat = 1.5
                
                // Draw subtle dots at grid intersections
                var x: CGFloat = 16 + 40 // Starting offset + half item width
                while x < size.width {
                    var y: CGFloat = 16 + 45 // Starting offset + half item height
                    while y < size.height {
                        let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(.gray.opacity(0.15)))
                        y += gridSize
                    }
                    x += gridSize
                }
            }
        }
    }
    
    private var editModeToolbar: some View {
        HStack(spacing: 12) {
            Text("\(viewModel.selectedApps.count) selected")
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Create Group") {
                showingNewGroupSheet = true
            }
            .disabled(viewModel.selectedApps.isEmpty)
            
            Button("Done") {
                viewModel.exitEditMode()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
    }
    
    // MARK: - Groups Section
    
    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Groups")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                let groupCount = viewModel.launcherTiles.filter { $0.isGroup }.count
                let appCount = viewModel.launcherTiles.filter { $0.isStandaloneApp }.count
                if appCount > 0 {
                    Text("\(groupCount) groups, \(appCount) apps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(groupCount) groups")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            
            // Custom grid layout that supports multi-row tiles
            GeometryReader { geometry in
                let availableWidth = geometry.size.width - 32 // Account for padding
                let spacing: CGFloat = 8
                let columns = max(1, Int((availableWidth + spacing) / (standardTileWidth + spacing)))
                let positions = calculateGridPositions(columns: columns)
                let gridHeight = calculateGridHeight(positions: positions, spacing: spacing)
                
                ZStack(alignment: .topLeading) {
                    ForEach(positions, id: \.tile.id) { position in
                        let tileW = CGFloat(position.colSpan) * standardTileWidth + CGFloat(position.colSpan - 1) * spacing
                        let tileH = CGFloat(position.rowSpan) * standardTileHeight + CGFloat(position.rowSpan - 1) * spacing
                        
                        tileView(for: position.tile, at: position.index)
                            .frame(width: tileW, height: tileH)
                            .position(
                                x: 16 + CGFloat(position.col) * (standardTileWidth + spacing) + tileW / 2,
                                y: CGFloat(position.row) * (standardTileHeight + spacing) + tileH / 2
                            )
                            .animation(.easeInOut(duration: 0.25), value: viewModel.launcherTiles)
                    }
                }
                .frame(width: geometry.size.width, height: gridHeight)
                .dropDestination(for: String.self) { items, location in
                    dropTargetGroupId = nil
                    guard let itemString = items.first else { return false }
                    
                    // Find which tile the drop landed on
                    let targetTile = findTile(at: location, in: positions, spacing: spacing)
                    
                    // Handle group drag (reordering)
                    if itemString.hasPrefix("group:") {
                        let groupIdString = String(itemString.dropFirst(6))
                        guard let sourceGroupId = UUID(uuidString: groupIdString) else { return false }
                        
                        // If dropped on a tile, move source to that tile's position
                        if let targetTile = targetTile {
                            if case .group(let targetGroupId) = targetTile.tile, sourceGroupId != targetGroupId {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.reorderGroup(from: sourceGroupId, to: targetGroupId)
                                }
                                return true
                            }
                            // Dropped on a standalone app tile - insert at that index
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.insertTileAt(groupId: sourceGroupId, index: targetTile.index)
                            }
                            return true
                        }
                        
                        // Dropped in a gap - find nearest insert position
                        let idx = findInsertIndex(at: location, in: positions, spacing: spacing)
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.insertTileAt(groupId: sourceGroupId, index: idx)
                        }
                        return true
                    }
                    
                    // Handle app drag (adding to group)
                    if let targetTile = targetTile,
                       case .group(let targetGroupId) = targetTile.tile,
                       let appId = UUID(uuidString: itemString),
                       let group = viewModel.groups.first(where: { $0.id == targetGroupId }) {
                        viewModel.moveAppToGroup(appId, group: group)
                        return true
                    }
                    
                    return false
                } isTargeted: { targeted in
                    if !targeted {
                        dropTargetGroupId = nil
                    }
                }
                .onAppear {
                    gridContentHeight = gridHeight
                }
                .onChange(of: positions.count) { _ in
                    gridContentHeight = gridHeight
                }
                .onChange(of: viewModel.launcherTiles) { _ in
                    // Recalculate after reorder
                    let newPositions = calculateGridPositions(columns: columns)
                    gridContentHeight = calculateGridHeight(positions: newPositions, spacing: spacing)
                }
            }
            .frame(height: gridContentHeight)
        }
    }
    
    private struct TileGridPosition {
        let tile: LauncherTile
        let index: Int
        let row: Int
        let col: Int
        let colSpan: Int
        let rowSpan: Int
        
        /// Get the rect for this tile position
        func rect(tileWidth: CGFloat, tileHeight: CGFloat, spacing: CGFloat) -> CGRect {
            let x = 16 + CGFloat(col) * (tileWidth + spacing)
            let y = CGFloat(row) * (tileHeight + spacing)
            let w = CGFloat(colSpan) * tileWidth + CGFloat(colSpan - 1) * spacing
            let h = CGFloat(rowSpan) * tileHeight + CGFloat(rowSpan - 1) * spacing
            return CGRect(x: x, y: y, width: w, height: h)
        }
    }
    
    /// Find which tile contains the given point
    private func findTile(at point: CGPoint, in positions: [TileGridPosition], spacing: CGFloat) -> TileGridPosition? {
        for position in positions {
            let rect = position.rect(tileWidth: standardTileWidth, tileHeight: standardTileHeight, spacing: spacing)
            if rect.contains(point) {
                return position
            }
        }
        return nil
    }
    
    /// Find the insert index for a drop between tiles
    private func findInsertIndex(at point: CGPoint, in positions: [TileGridPosition], spacing: CGFloat) -> Int {
        guard !positions.isEmpty else { return 0 }
        
        // Find the closest tile and insert before or after it
        var closestIndex = 0
        var closestDistance: CGFloat = .infinity
        
        for position in positions {
            let rect = position.rect(tileWidth: standardTileWidth, tileHeight: standardTileHeight, spacing: spacing)
            let centerX = rect.midX
            let centerY = rect.midY
            let distance = hypot(point.x - centerX, point.y - centerY)
            
            if distance < closestDistance {
                closestDistance = distance
                // Insert after if drop is to the right of center, before otherwise
                closestIndex = point.x > centerX ? position.index + 1 : position.index
            }
        }
        
        return closestIndex
    }
    
    /// Estimate grid height for GeometryReader
    private func estimateGridHeight() -> CGFloat {
        let availableWidth: CGFloat = 800 // Reasonable estimate
        let spacing: CGFloat = 8
        let columns = max(1, Int((availableWidth + spacing) / (standardTileWidth + spacing)))
        let positions = calculateGridPositions(columns: columns)
        return calculateGridHeight(positions: positions, spacing: spacing)
    }
    
    /// Calculate total grid height from positions
    private func calculateGridHeight(positions: [TileGridPosition], spacing: CGFloat) -> CGFloat {
        guard !positions.isEmpty else { return standardTileHeight }
        let maxRow = positions.map { $0.row + $0.rowSpan }.max() ?? 1
        return CGFloat(maxRow) * standardTileHeight + CGFloat(max(0, maxRow - 1)) * spacing
    }
    
    /// Calculate grid positions for all tiles using bin-packing algorithm
    private func calculateGridPositions(columns: Int) -> [TileGridPosition] {
        var positions: [TileGridPosition] = []
        var grid: [[Bool]] = [] // Dynamic grid: grid[row][col] = occupied
        
        func ensureRows(_ rowCount: Int) {
            while grid.count < rowCount {
                grid.append(Array(repeating: false, count: columns))
            }
        }
        
        func isAvailable(row: Int, col: Int, rowSpan: Int, colSpan: Int) -> Bool {
            if col + colSpan > columns { return false }
            ensureRows(row + rowSpan)
            for r in row..<(row + rowSpan) {
                for c in col..<(col + colSpan) {
                    if grid[r][c] { return false }
                }
            }
            return true
        }
        
        func occupy(row: Int, col: Int, rowSpan: Int, colSpan: Int) {
            ensureRows(row + rowSpan)
            for r in row..<(row + rowSpan) {
                for c in col..<(col + colSpan) {
                    grid[r][c] = true
                }
            }
        }
        
        func findPosition(rowSpan: Int, colSpan: Int) -> (row: Int, col: Int) {
            var row = 0
            while row < 100 { // Safety limit
                ensureRows(row + rowSpan)
                for col in 0..<columns {
                    if isAvailable(row: row, col: col, rowSpan: rowSpan, colSpan: colSpan) {
                        return (row, col)
                    }
                }
                row += 1
            }
            return (row, 0)
        }
        
        for (index, tile) in viewModel.launcherTiles.enumerated() {
            let colSpan: Int
            let rowSpan: Int
            
            switch tile {
            case .group(let groupId):
                if let group = viewModel.groups.first(where: { $0.id == groupId }) {
                    colSpan = min(group.tileSize.gridSpanWidth, columns)
                    rowSpan = group.tileSize.gridSpanHeight
                } else {
                    colSpan = 1
                    rowSpan = 1
                }
            case .standaloneApp:
                colSpan = 1
                rowSpan = 1
            }
            
            let (row, col) = findPosition(rowSpan: rowSpan, colSpan: colSpan)
            occupy(row: row, col: col, rowSpan: rowSpan, colSpan: colSpan)
            
            positions.append(TileGridPosition(
                tile: tile,
                index: index,
                row: row,
                col: col,
                colSpan: colSpan,
                rowSpan: rowSpan
            ))
        }
        
        return positions
    }
    
    private let tileSpacing: CGFloat = 8
    
    /// Get the width for a specific tile (accounting for spacing when spanning multiple tiles)
    private func tileWidth(for tile: LauncherTile) -> CGFloat {
        switch tile {
        case .group(let groupId):
            if let group = viewModel.groups.first(where: { $0.id == groupId }) {
                let span = group.tileSize.gridSpanWidth
                // Width = span * standardTileWidth + (span - 1) * spacing
                return CGFloat(span) * standardTileWidth + CGFloat(span - 1) * tileSpacing
            }
            return standardTileWidth
        case .standaloneApp:
            return standardTileWidth
        }
    }
    
    /// Get the height for a specific tile (accounting for spacing when spanning multiple tiles)
    private func tileHeight(for tile: LauncherTile) -> CGFloat {
        switch tile {
        case .group(let groupId):
            if let group = viewModel.groups.first(where: { $0.id == groupId }) {
                let span = group.tileSize.gridSpanHeight
                // Height = span * standardTileHeight + (span - 1) * spacing
                return CGFloat(span) * standardTileHeight + CGFloat(span - 1) * tileSpacing
            }
            return standardTileHeight
        case .standaloneApp:
            return standardTileHeight
        }
    }
    
    /// Simple tile view for the grid
    @ViewBuilder
    private func tileView(for tile: LauncherTile, at index: Int) -> some View {
        switch tile {
        case .group(let groupId):
            if let group = viewModel.groups.first(where: { $0.id == groupId }) {
                groupIcon(for: group, isDropTarget: dropTargetGroupId == groupId)
            }
        case .standaloneApp(let appId):
            if let app = viewModel.standaloneApp(for: appId) {
                standaloneAppTile(for: app)
            }
        }
    }
    
    /// Handle drops on a group tile - for reordering groups or adding apps
    private func handleGroupDrop(items: [String], targetGroupId: UUID) -> Bool {
        print("DEBUG: handleGroupDrop called with items: \(items) target: \(targetGroupId)")
        
        // Write to file for debugging
        let debugMsg = "handleGroupDrop: items=\(items) target=\(targetGroupId)\n"
        if let data = debugMsg.data(using: .utf8) {
            FileManager.default.createFile(atPath: "/tmp/drop_debug.log", contents: data)
        }
        
        guard let itemString = items.first else { return false }
        
        // Handle group drag (reordering)
        if itemString.hasPrefix("group:") {
            let groupIdString = String(itemString.dropFirst(6))
            if let sourceGroupId = UUID(uuidString: groupIdString), sourceGroupId != targetGroupId {
                viewModel.reorderGroup(from: sourceGroupId, to: targetGroupId)
                return true
            }
            return false
        }
        
        // Handle app drag (adding to group)
        if let appId = UUID(uuidString: itemString) {
            viewModel.moveAppToGroup(appId, group: viewModel.groups.first(where: { $0.id == targetGroupId })!)
            return true
        }
        
        return false
    }
    
    private func standaloneAppTile(for app: AppItem) -> some View {
        StandaloneAppTileView(
            app: app,
            isEditMode: viewModel.isEditMode,
            scale: viewModel.groupTileScale,
            onTap: {
                viewModel.launchApp(app)
            },
            onUnpin: {
                viewModel.unpinStandaloneApp(app.id)
            },
            onMoveToGroup: { group in
                viewModel.moveAppToGroup(app.id, group: group)
                // Also remove from tiles since it's now in a group
                viewModel.launcherTiles.removeAll { $0.uuid == app.id && $0.isStandaloneApp }
                viewModel.saveData()
            },
            groups: viewModel.groups
        )
    }
    
    private func handleTileInsertDrop(items: [String], atIndex insertIndex: Int) -> Bool {
        guard let itemString = items.first else { return false }
        
        // Handle group drag
        if itemString.hasPrefix("group:") {
            let groupIdString = String(itemString.dropFirst(6))
            if let groupId = UUID(uuidString: groupIdString) {
                let tileId = "group:\(groupId.uuidString)"
                viewModel.insertTile(from: tileId, toIndex: insertIndex)
                tileInsertIndex = nil
                return true
            }
        }
        
        // Handle standalone app drag
        if itemString.hasPrefix("standaloneApp:") {
            let appIdString = String(itemString.dropFirst(14))
            if let appId = UUID(uuidString: appIdString) {
                let tileId = "app:\(appId.uuidString)"
                viewModel.insertTile(from: tileId, toIndex: insertIndex)
                tileInsertIndex = nil
                return true
            }
        }
        
        // Handle app from ungrouped being pinned
        if let appId = UUID(uuidString: itemString) {
            viewModel.pinAppAsStandalone(appId)
            // Move it to the right position
            if let tileIndex = viewModel.launcherTiles.firstIndex(where: { $0.uuid == appId && $0.isStandaloneApp }) {
                let movedTile = viewModel.launcherTiles.remove(at: tileIndex)
                let adjustedIndex = min(insertIndex, viewModel.launcherTiles.count)
                viewModel.launcherTiles.insert(movedTile, at: adjustedIndex)
                viewModel.saveData()
            }
            tileInsertIndex = nil
            return true
        }
        
        return false
    }
    
    private func handleGroupSwapDrop(items: [String], withGroup targetGroup: AppGroup) -> Bool {
        guard let uuidString = items.first,
              uuidString.hasPrefix("group:") else {
            return false
        }
        
        let groupIdString = String(uuidString.dropFirst(6))
        if let sourceGroupId = UUID(uuidString: groupIdString), sourceGroupId != targetGroup.id {
            viewModel.reorderGroup(from: sourceGroupId, to: targetGroup.id)
            dropTargetGroupId = nil
            return true
        }
        return false
    }
    
    private func handleGroupInsertDrop(items: [String], atIndex insertIndex: Int) -> Bool {
        guard let uuidString = items.first,
              uuidString.hasPrefix("group:") else {
            return false
        }
        
        let groupIdString = String(uuidString.dropFirst(6))
        if let sourceGroupId = UUID(uuidString: groupIdString) {
            viewModel.insertGroup(from: sourceGroupId, toIndex: insertIndex)
            groupInsertIndex = nil
            return true
        }
        return false
    }
    
    private func groupIcon(for group: AppGroup, isDropTarget: Bool = false) -> some View {
        GroupIconView(
            group: group,
            apps: viewModel.apps(for: group),
            isEditMode: viewModel.isEditMode,
            isCollapsed: viewModel.isGroupCollapsed(group),
            scale: viewModel.groupTileScale,
            onTap: {
                viewModel.expandGroup(group)
            },
            onDropApp: { appId in
                viewModel.moveAppToGroup(appId, group: group)
            },
            onReorderGroup: { sourceGroupId in
                viewModel.reorderGroup(from: sourceGroupId, to: group.id)
            },
            onToggleCollapse: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleGroupExpansion(group)
                }
            },
            onChangeTileSize: { newSize in
                viewModel.setGroupTileSize(group, size: newSize)
            },
            isDropTarget: isDropTarget
        )
        .contextMenu {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleGroupExpansion(group)
                }
            } label: {
                Label(viewModel.isGroupCollapsed(group) ? "Expand Group" : "Collapse Group", 
                      systemImage: viewModel.isGroupCollapsed(group) ? "chevron.down.circle" : "chevron.up.circle")
            }
            
            Button {
                viewModel.editingGroupId = group.id
                viewModel.expandGroup(group)
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Divider()
            
            Menu("Resize Group") {
                ForEach(GroupTileSize.allCases, id: \.self) { size in
                    Button {
                        viewModel.setGroupTileSize(group, size: size)
                    } label: {
                        HStack {
                            Text(size.displayName)
                            if group.tileSize == size {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            Button(role: .destructive) {
                viewModel.deleteGroup(group)
            } label: {
                Label("Delete Group", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Apps Section
    
    private var appsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleAppsSection()
                }
            }) {
                HStack {
                    Image(systemName: viewModel.isAppsSectionCollapsed ? "chevron.right" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    
                    Text("Apps")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(viewModel.filteredUngroupedApps.count) apps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            
            if !viewModel.isAppsSectionCollapsed {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredUngroupedApps) { app in
                        appIcon(for: app)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func appIcon(for app: AppItem) -> some View {
        DraggableAppIconView(
            app: app,
            isSelected: viewModel.selectedApps.contains(app.id),
            isEditMode: viewModel.isEditMode,
            groups: viewModel.groups,
            draggedAppId: $draggedAppId,
            onTap: { modifiers in handleAppTap(app, modifiers: modifiers) },
            onLongPress: { handleAppLongPress(app) },
            onAddToGroup: { group in
                // If this app is part of a multi-selection, move all selected apps
                if viewModel.selectedApps.contains(app.id) && viewModel.selectedApps.count > 1 {
                    viewModel.addToGroup(group)
                } else {
                    viewModel.moveAppToGroup(app.id, group: group)
                }
            },
            onCreateNewGroup: {
                // If this app is part of a multi-selection, create group with all selected apps
                if viewModel.selectedApps.contains(app.id) && viewModel.selectedApps.count > 1 {
                    appForNewGroup = nil  // nil signals to use selectedApps
                } else {
                    appForNewGroup = app
                }
                showingNewGroupSheet = true
            },
            onDropOntoApp: { droppedAppId in
                viewModel.createGroupFromApps(app.id, droppedAppId)
            },
            onReorderApp: { sourceAppId in
                viewModel.reorderUngroupedApp(from: sourceAppId, to: app.id)
            },
            onPinToGrid: {
                viewModel.pinAppAsStandalone(app.id)
            }
        )
    }
    
    // MARK: - Expanded Group Overlay
    
    @ViewBuilder
    private var expandedGroupOverlay: some View {
        if let expandedGroupId = viewModel.expandedGroupId,
           let group = viewModel.groups.first(where: { $0.id == expandedGroupId }) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.collapseGroup()
                }
            
            ExpandedGroupView(
                group: group,
                appLookup: viewModel.appLookup,
                allGroups: viewModel.groups,
                isEditingName: viewModel.editingGroupId == group.id,
                headerColor: $viewModel.groupHeaderColor,
                onClose: {
                    viewModel.editingGroupId = nil
                    viewModel.collapseGroup()
                },
                onRename: { newName in
                    viewModel.renameGroup(group, to: newName)
                },
                onStartRename: {
                    viewModel.editingGroupId = group.id
                },
                onAppTap: { app in
                    viewModel.launchApp(app)
                    viewModel.collapseGroup()
                },
                onAddAppToGroup: { app, targetGroup in
                    viewModel.moveAppToGroup(app.id, group: targetGroup)
                },
                onCreateNewGroupWithApp: { app in
                    appForNewGroup = app
                    showingNewGroupSheet = true
                },
                onRemoveAppFromGroup: { app in
                    viewModel.removeAppFromCurrentGroup(app.id)
                },
                onReorderAppsInGroup: { appId, targetIndex in
                    viewModel.reorderAppInGroup(appId, in: group, toIndex: targetIndex)
                },
                onSwapAppsInGroup: { appId, targetIndex in
                    viewModel.swapAppsInGroup(appId, withAppAtIndex: targetIndex, in: group)
                }
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button {
                // Keep expanded group open so user can see real-time color changes
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showSettings.toggle()
                }
            } label: {
                Image(systemName: "gearshape")
            }
            .help("Settings")
            
            TextField("Search apps...", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 180)
                .overlay(alignment: .trailing) {
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 6)
                    }
                }
            
            Spacer()
            
            Button {
                viewModel.refreshApps()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .help("Refresh apps")
            
            Button {
                if viewModel.isEditMode {
                    viewModel.exitEditMode()
                } else {
                    viewModel.enterEditMode()
                    // Scroll to apps section after a brief delay to allow expansion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy?.scrollTo("appsSection", anchor: .top)
                        }
                    }
                }
            } label: {
                Image(systemName: viewModel.isEditMode ? "checkmark.circle.fill" : "square.and.pencil")
            }
            .help(viewModel.isEditMode ? "Exit edit mode" : "Enter edit mode")
        }
    }
    
    // MARK: - New Group Sheet
    
    private var newGroupSheet: some View {
        VStack(spacing: 20) {
            Text("Create New Group")
                .font(.headline)
            
            if let app = appForNewGroup {
                Text("with \(app.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if !viewModel.selectedApps.isEmpty {
                Text("with \(viewModel.selectedApps.count) selected apps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            TextField("Group name", text: $newGroupName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)
                .onSubmit {
                    createNewGroup()
                }
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    newGroupName = ""
                    appForNewGroup = nil
                    showingNewGroupSheet = false
                }
                .keyboardShortcut(.escape)
                
                Button("Create") {
                    createNewGroup()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 320)
    }
    
    // MARK: - Actions
    
    private func handleAppTap(_ app: AppItem, modifiers: NSEvent.ModifierFlags) {
        if viewModel.isEditMode {
            let shiftKey = modifiers.contains(.shift)
            let commandKey = modifiers.contains(.command)
            
            viewModel.selectWithModifiers(app, shiftKey: shiftKey, commandKey: commandKey, appList: viewModel.filteredUngroupedApps)
        } else {
            viewModel.launchApp(app)
        }
    }
    
    private func handleAppLongPress(_ app: AppItem) {
        if !viewModel.isEditMode {
            viewModel.enterEditMode()
        }
        viewModel.toggleSelection(app)
    }
    
    private func createNewGroup() {
        if let app = appForNewGroup {
            viewModel.createGroupWithApp(named: newGroupName.isEmpty ? "New Group" : newGroupName, app: app)
        } else if !viewModel.selectedApps.isEmpty {
            viewModel.createGroup(named: newGroupName.isEmpty ? "New Group" : newGroupName)
        }
        newGroupName = ""
        appForNewGroup = nil
        showingNewGroupSheet = false
    }
}
