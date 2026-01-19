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
    
    private var groupGridColumns: [GridItem] {
        let baseSize: CGFloat = 120 * viewModel.groupTileScale
        return [GridItem(.adaptive(minimum: baseSize, maximum: baseSize + 30), spacing: 2)]
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
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
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
            }
            .padding(.vertical, 16)
        }
        .background(gridBackground.opacity(viewModel.backgroundOpacity))
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            settingsHeader
            settingsControls
        }
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
        .cornerRadius(12)
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
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Groups Section
    
    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Groups")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.groups.count) groups")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            
            LazyVGrid(columns: groupGridColumns, spacing: 2) {
                ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { index, group in
                    groupIconWithDropZones(for: group, at: index)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func groupIconWithDropZones(for group: AppGroup, at index: Int) -> some View {
        HStack(spacing: 0) {
            // Left drop zone for insert
            Rectangle()
                .fill(groupInsertIndex == index ? Color.blue.opacity(0.3) : Color.clear)
                .frame(width: 8)
                .dropDestination(for: String.self) { items, _ in
                    handleGroupInsertDrop(items: items, atIndex: index)
                } isTargeted: { targeted in
                    groupInsertIndex = targeted ? index : nil
                }
            
            groupIcon(for: group)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(dropTargetGroupId == group.id ? Color.blue : Color.clear, lineWidth: 3)
                        .padding(4)
                )
                .dropDestination(for: String.self) { items, _ in
                    handleGroupSwapDrop(items: items, withGroup: group)
                } isTargeted: { targeted in
                    dropTargetGroupId = targeted ? group.id : nil
                }
            
            // Right drop zone for insert (for last item)
            if index == viewModel.groups.count - 1 {
                Rectangle()
                    .fill(groupInsertIndex == index + 1 ? Color.blue.opacity(0.3) : Color.clear)
                    .frame(width: 8)
                    .dropDestination(for: String.self) { items, _ in
                        handleGroupInsertDrop(items: items, atIndex: index + 1)
                    } isTargeted: { targeted in
                        groupInsertIndex = targeted ? index + 1 : nil
                    }
            }
        }
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
    
    private func groupIcon(for group: AppGroup) -> some View {
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
            }
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
            onTap: { handleAppTap(app) },
            onLongPress: { handleAppLongPress(app) },
            onAddToGroup: { group in viewModel.moveAppToGroup(app.id, group: group) },
            onCreateNewGroup: {
                appForNewGroup = app
                showingNewGroupSheet = true
            },
            onDropOntoApp: { droppedAppId in
                viewModel.createGroupFromApps(app.id, droppedAppId)
            },
            onReorderApp: { sourceAppId in
                viewModel.reorderUngroupedApp(from: sourceAppId, to: app.id)
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
                headerColor: viewModel.groupHeaderColor,
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
            }
            
            TextField("Group name", text: $newGroupName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)
            
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
    
    private func handleAppTap(_ app: AppItem) {
        if viewModel.isEditMode {
            viewModel.toggleSelection(app)
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
