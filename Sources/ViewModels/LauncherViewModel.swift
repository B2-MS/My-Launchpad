import SwiftUI
import Combine

/// Main view model that manages all launcher state
@MainActor
class LauncherViewModel: ObservableObject {
    @Published var allApps: [AppItem] = []
    @Published var groups: [AppGroup] = []
    @Published var ungroupedAppIds: [UUID] = []
    @Published var isEditMode: Bool = false
    @Published var selectedApps: Set<UUID> = []
    @Published var lastSelectedAppId: UUID? = nil  // For Shift+click range selection
    @Published var searchText: String = ""
    @Published var editingGroupId: UUID? = nil
    @Published var isGroupsSectionCollapsed: Bool = false
    @Published var isAppsSectionCollapsed: Bool = true
    @Published var backgroundOpacity: Double = 1.0
    @Published var windowOpacity: Double = 0.5
    @Published var groupHeaderColor: Color = .purple
    @Published var groupTileScale: Double = 1.1
    @Published var hideOnLaunch: Bool = true
    @Published var hideOnFocusLost: Bool = true
    @Published var showSettings: Bool = false
    @Published var windowWidth: Double = 800
    @Published var windowHeight: Double = 600
    
    private let dataManager = DataManager.shared
    
    init() {
        loadData()
    }
    
    /// Apps that are not in any group
    var ungroupedApps: [AppItem] {
        allApps.filter { ungroupedAppIds.contains($0.id) }
    }
    
    /// Dictionary lookup for apps by ID
    var appLookup: [UUID: AppItem] {
        Dictionary(uniqueKeysWithValues: allApps.map { ($0.id, $0) })
    }
    
    /// Filtered apps based on search
    var filteredUngroupedApps: [AppItem] {
        if searchText.isEmpty {
            return ungroupedApps
        }
        return ungroupedApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    /// Get apps for a specific group
    func apps(for group: AppGroup) -> [AppItem] {
        let groupApps = group.appIds.compactMap { appId in
            allApps.first { $0.id == appId }
        }
        if searchText.isEmpty {
            return groupApps
        }
        return groupApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    /// Load data from persistence or scan fresh
    func loadData() {
        if let savedData = dataManager.load() {
            // Merge saved data with fresh scan to catch new apps
            let freshApps = AppScanner.scanApplications()
            let savedAppPaths = Set(savedData.allApps.map { $0.path })
            
            // Keep saved apps that still exist
            var validApps = savedData.allApps.filter { AppScanner.appExists($0) }
            let validAppIds = Set(validApps.map { $0.id })
            
            // Add new apps not in saved data
            let newApps = freshApps.filter { !savedAppPaths.contains($0.path) }
            validApps.append(contentsOf: newApps)
            
            self.allApps = validApps
            
            // Update groups - remove invalid app IDs but keep voids
            self.groups = savedData.groups.map { group in
                var updatedGroup = group
                updatedGroup.appIds = group.appIds.filter { 
                    AppGroup.isVoid($0) || validAppIds.contains($0) 
                }
                return updatedGroup
            }
            
            // Update ungrouped - remove invalid and add new
            var ungrouped = savedData.ungroupedAppIds.filter { validAppIds.contains($0) }
            ungrouped.append(contentsOf: newApps.map { $0.id })
            self.ungroupedAppIds = ungrouped
            
            // Restore settings
            if let scale = savedData.groupTileScale {
                self.groupTileScale = scale
            }
            if let hide = savedData.hideOnLaunch {
                self.hideOnLaunch = hide
            }
            if let hideFocus = savedData.hideOnFocusLost {
                self.hideOnFocusLost = hideFocus
            }
            if let width = savedData.windowWidth {
                self.windowWidth = width
            }
            if let height = savedData.windowHeight {
                self.windowHeight = height
            }
            
        } else {
            // First run - scan all apps
            let freshApps = AppScanner.scanApplications()
            self.allApps = freshApps
            self.ungroupedAppIds = freshApps.map { $0.id }
            self.groups = []
        }
        
        saveData()
    }
    
    /// Refresh apps from disk
    func refreshApps() {
        loadData()
    }
    
    /// Save current state
    func saveData() {
        let data = LauncherData(
            groups: groups,
            ungroupedAppIds: ungroupedAppIds,
            allApps: allApps,
            groupTileScale: groupTileScale,
            hideOnLaunch: hideOnLaunch,
            hideOnFocusLost: hideOnFocusLost,
            windowWidth: windowWidth,
            windowHeight: windowHeight
        )
        dataManager.save(data)
    }
    
    /// Launch an app and optionally hide the launcher window
    func launchApp(_ app: AppItem) {
        if !isEditMode {
            app.launch()
            // Hide the launcher window after launching an app if enabled
            if hideOnLaunch {
                NSApplication.shared.hide(nil)
            }
        }
    }
    
    /// Toggle app selection in edit mode
    func toggleSelection(_ app: AppItem) {
        if selectedApps.contains(app.id) {
            selectedApps.remove(app.id)
        } else {
            selectedApps.insert(app.id)
        }
        lastSelectedAppId = app.id
    }
    
    /// Handle selection with modifier keys (Shift, Command)
    /// - Parameters:
    ///   - app: The app that was clicked
    ///   - shiftKey: True if Shift is held (range selection)
    ///   - commandKey: True if Command is held (toggle individual)
    ///   - appList: The ordered list of apps to use for range selection
    func selectWithModifiers(_ app: AppItem, shiftKey: Bool, commandKey: Bool, appList: [AppItem]) {
        if shiftKey, let lastId = lastSelectedAppId {
            // Shift+click: Select range from last selected to current
            selectRange(from: lastId, to: app.id, in: appList)
        } else if commandKey {
            // Command+click: Toggle individual selection
            toggleSelection(app)
        } else {
            // Plain click: Clear selection and select only this one
            selectedApps.removeAll()
            selectedApps.insert(app.id)
            lastSelectedAppId = app.id
        }
    }
    
    /// Select a range of apps between two app IDs
    private func selectRange(from startId: UUID, to endId: UUID, in appList: [AppItem]) {
        guard let startIndex = appList.firstIndex(where: { $0.id == startId }),
              let endIndex = appList.firstIndex(where: { $0.id == endId }) else {
            return
        }
        
        let range = min(startIndex, endIndex)...max(startIndex, endIndex)
        for index in range {
            selectedApps.insert(appList[index].id)
        }
        lastSelectedAppId = endId
    }
    
    /// Create a new group with selected apps
    func createGroup(named name: String) {
        guard !selectedApps.isEmpty else { return }
        
        // Calculate position for new group (stagger from existing groups)
        let offsetX = Double(groups.count % 3) * 300 + 50
        let offsetY = Double(groups.count / 3) * 220 + 50
        
        let newGroup = AppGroup(
            name: name,
            appIds: Array(selectedApps),
            order: groups.count,
            positionX: offsetX,
            positionY: offsetY
        )
        
        groups.append(newGroup)
        
        // Remove from ungrouped
        ungroupedAppIds.removeAll { selectedApps.contains($0) }
        
        // Remove from other groups
        for i in groups.indices where groups[i].id != newGroup.id {
            groups[i].appIds.removeAll { selectedApps.contains($0) }
        }
        
        selectedApps.removeAll()
        isEditMode = false
        saveData()
    }
    
    /// Create a new group with a single app (from context menu)
    func createGroupWithApp(named name: String, app: AppItem) {
        // Calculate position for new group (stagger from existing groups)
        let offsetX = Double(groups.count % 3) * 300 + 50
        let offsetY = Double(groups.count / 3) * 220 + 50
        
        let newGroup = AppGroup(
            name: name,
            appIds: [app.id],
            order: groups.count,
            positionX: offsetX,
            positionY: offsetY
        )
        
        groups.append(newGroup)
        
        // Remove from ungrouped
        ungroupedAppIds.removeAll { $0 == app.id }
        
        // Remove from other groups
        for i in groups.indices where groups[i].id != newGroup.id {
            groups[i].appIds.removeAll { $0 == app.id }
        }
        
        saveData()
    }
    
    /// Add selected apps to existing group
    func addToGroup(_ group: AppGroup) {
        guard !selectedApps.isEmpty else { return }
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        
        // Add to target group
        let newAppIds = selectedApps.filter { !groups[index].appIds.contains($0) }
        groups[index].appIds.append(contentsOf: newAppIds)
        
        // Remove from ungrouped
        ungroupedAppIds.removeAll { selectedApps.contains($0) }
        
        // Remove from other groups
        for i in groups.indices where groups[i].id != group.id {
            groups[i].appIds.removeAll { selectedApps.contains($0) }
        }
        
        selectedApps.removeAll()
        saveData()
    }
    
    /// Remove apps from a group (move to ungrouped)
    func removeFromGroup(_ appIds: Set<UUID>, group: AppGroup) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        
        groups[index].appIds.removeAll { appIds.contains($0) }
        ungroupedAppIds.append(contentsOf: appIds)
        
        saveData()
    }
    
    /// Rename a group
    func renameGroup(_ group: AppGroup, to newName: String) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[index].name = newName
        editingGroupId = nil
        saveData()
    }
    
    /// Delete a group (apps move to ungrouped)
    func deleteGroup(_ group: AppGroup) {
        ungroupedAppIds.append(contentsOf: group.appIds)
        groups.removeAll { $0.id == group.id }
        saveData()
    }
    
    /// Toggle group expansion (collapse/expand individual group icon)
    func toggleGroupExpansion(_ group: AppGroup) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[index].isExpanded.toggle()
        saveData()
    }
    
    /// Check if a group is collapsed
    func isGroupCollapsed(_ group: AppGroup) -> Bool {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return false }
        return !groups[index].isExpanded
    }
    
    /// Exit edit mode
    func exitEditMode() {
        isEditMode = false
        selectedApps.removeAll()
    }
    
    /// Enter edit mode
    func enterEditMode() {
        isEditMode = true
    }
    
    /// Move a single app to a specific group (for drag and drop)
    func moveAppToGroup(_ appId: UUID, group: AppGroup) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        
        // Don't add if already in this group
        guard !groups[index].appIds.contains(appId) else { return }
        
        // Remove from ungrouped
        ungroupedAppIds.removeAll { $0 == appId }
        
        // Remove from all other groups
        for i in groups.indices where groups[i].id != group.id {
            groups[i].appIds.removeAll { $0 == appId }
        }
        
        // Add to target group
        groups[index].appIds.append(appId)
        
        saveData()
    }
    
    /// Move a single app to ungrouped (for drag and drop)
    func moveAppToUngrouped(_ appId: UUID) {
        // Don't add if already ungrouped
        guard !ungroupedAppIds.contains(appId) else { return }
        
        // Remove from all groups
        for i in groups.indices {
            groups[i].appIds.removeAll { $0 == appId }
        }
        
        // Add to ungrouped
        ungroupedAppIds.append(appId)
        
        saveData()
    }
    
    /// Update group position (for drag and drop positioning)
    func updateGroupPosition(_ group: AppGroup, x: Double, y: Double) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[index].positionX = x
        groups[index].positionY = y
        saveData()
    }
    
    /// Bring a group to the front (highest z-order)
    func bringGroupToFront(_ group: AppGroup) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        let movedGroup = groups.remove(at: index)
        groups.append(movedGroup)
        // Don't save here to avoid excessive writes during dragging
    }
    
    /// Create a new group by combining two apps (iOS-style drag one onto another)
    func createGroupFromApps(_ app1Id: UUID, _ app2Id: UUID, named name: String = "New Folder") {
        // Don't create if same app
        guard app1Id != app2Id else { return }
        
        // Calculate position for new group
        let offsetX = Double(groups.count % 5) * 100 + 50
        let offsetY = Double(groups.count / 5) * 100 + 50
        
        let newGroup = AppGroup(
            name: name,
            appIds: [app1Id, app2Id],
            order: groups.count,
            positionX: offsetX,
            positionY: offsetY
        )
        
        groups.append(newGroup)
        
        // Remove both from ungrouped
        ungroupedAppIds.removeAll { $0 == app1Id || $0 == app2Id }
        
        // Remove from other groups
        for i in groups.indices where groups[i].id != newGroup.id {
            groups[i].appIds.removeAll { $0 == app1Id || $0 == app2Id }
        }
        
        saveData()
    }
    
    /// Remove a single app from its current group and move to ungrouped
    func removeAppFromCurrentGroup(_ appId: UUID) {
        // Remove from all groups
        for i in groups.indices {
            groups[i].appIds.removeAll { $0 == appId }
        }
        
        // Add to ungrouped if not already there
        if !ungroupedAppIds.contains(appId) {
            ungroupedAppIds.append(appId)
        }
        
        saveData()
    }
    
    /// Get the expanded group (only one at a time)
    @Published var expandedGroupId: UUID? = nil
    
    /// Expand a group (close others and close settings)
    func expandGroup(_ group: AppGroup) {
        showSettings = false
        expandedGroupId = group.id
    }
    
    /// Collapse the currently expanded group
    func collapseGroup() {
        expandedGroupId = nil
    }
    
    /// Toggle the groups section collapsed state
    func toggleGroupsSection() {
        isGroupsSectionCollapsed.toggle()
    }
    
    /// Toggle the apps section collapsed state
    func toggleAppsSection() {
        isAppsSectionCollapsed.toggle()
    }
    
    /// Reorder an ungrouped app by moving it to a new index
    func reorderUngroupedApp(from sourceId: UUID, to targetId: UUID) {
        guard let sourceIndex = ungroupedAppIds.firstIndex(of: sourceId),
              let targetIndex = ungroupedAppIds.firstIndex(of: targetId),
              sourceIndex != targetIndex else { return }
        
        let movedId = ungroupedAppIds.remove(at: sourceIndex)
        ungroupedAppIds.insert(movedId, at: targetIndex)
        saveData()
    }
    
    /// Reorder groups by moving one group to another's position (swap)
    func reorderGroup(from sourceId: UUID, to targetId: UUID) {
        guard let sourceIndex = groups.firstIndex(where: { $0.id == sourceId }),
              let targetIndex = groups.firstIndex(where: { $0.id == targetId }),
              sourceIndex != targetIndex else { return }
        
        let movedGroup = groups.remove(at: sourceIndex)
        groups.insert(movedGroup, at: targetIndex)
        saveData()
    }
    
    /// Insert a group at a specific index
    func insertGroup(from sourceId: UUID, toIndex targetIndex: Int) {
        guard let sourceIndex = groups.firstIndex(where: { $0.id == sourceId }) else { return }
        
        // Don't do anything if dropping in same position
        if sourceIndex == targetIndex || sourceIndex == targetIndex - 1 {
            return
        }
        
        let movedGroup = groups.remove(at: sourceIndex)
        
        // Adjust target index if we removed before it
        var adjustedTargetIndex = targetIndex
        if sourceIndex < targetIndex {
            adjustedTargetIndex -= 1
        }
        
        // Insert at target position (clamped to valid range)
        let clampedIndex = min(max(0, adjustedTargetIndex), groups.count)
        groups.insert(movedGroup, at: clampedIndex)
        saveData()
    }

    /// Reorder an app within a group to a specific index (for pagination and drag/drop)
    /// Voids are allowed at the END of each page to enable cross-page moves
    /// Apps are always contiguous within a page (no gaps)
    func reorderAppInGroup(_ appId: UUID, in group: AppGroup, toIndex targetIndex: Int) {
        guard let groupIndex = groups.firstIndex(where: { $0.id == group.id }) else { return }
        guard let currentIndex = groups[groupIndex].appIds.firstIndex(of: appId) else { return }
        
        let appsPerPage = 16
        
        let currentPage = currentIndex / appsPerPage
        let targetPage = targetIndex / appsPerPage
        
        // Don't do anything if dropping in same position
        if currentIndex == targetIndex || currentIndex == targetIndex - 1 {
            return
        }
        
        // Check if moving to a different page
        let isMovingToNewPage = currentPage != targetPage
        
        if isMovingToNewPage {
            // Cross-page move: leave a void on source page, insert on target page
            
            // Step 1: Replace the app with a void at its current position
            groups[groupIndex].appIds[currentIndex] = AppGroup.voidId
            
            // Step 2: Compact the source page - move the void to the end of apps on that page
            compactPage(groupIndex: groupIndex, page: currentPage, appsPerPage: appsPerPage)
            
            // Step 3: Find where to insert on the target page
            // First, check if there's a void on the target page we can fill
            let targetPageStart = targetPage * appsPerPage
            let targetPageEnd = min(targetPageStart + appsPerPage, groups[groupIndex].appIds.count)
            
            var voidIndexOnTargetPage: Int? = nil
            if targetPageStart < groups[groupIndex].appIds.count {
                for i in targetPageStart..<targetPageEnd {
                    if i < groups[groupIndex].appIds.count && groups[groupIndex].appIds[i] == AppGroup.voidId {
                        voidIndexOnTargetPage = i
                        break
                    }
                }
            }
            
            if let voidIndex = voidIndexOnTargetPage {
                // Replace the void with the app
                groups[groupIndex].appIds[voidIndex] = appId
            } else {
                // No void on target page - insert at the target position
                let clampedTarget = min(targetIndex, groups[groupIndex].appIds.count)
                groups[groupIndex].appIds.insert(appId, at: clampedTarget)
            }
            
            // Step 4: Compact the target page as well
            compactPage(groupIndex: groupIndex, page: targetPage, appsPerPage: appsPerPage)
            
            // Step 5: Clean up trailing voids
            cleanupTrailingVoids(groupIndex: groupIndex)
        } else {
            // Same page move - just reorder normally (no voids needed)
            groups[groupIndex].appIds.remove(at: currentIndex)
            
            var adjustedTargetIndex = targetIndex
            if currentIndex < targetIndex {
                adjustedTargetIndex -= 1
            }
            
            let clampedIndex = min(max(0, adjustedTargetIndex), groups[groupIndex].appIds.count)
            groups[groupIndex].appIds.insert(appId, at: clampedIndex)
        }
        
        saveData()
    }
    
    /// Compact a page so apps are contiguous and voids are at the end
    private func compactPage(groupIndex: Int, page: Int, appsPerPage: Int) {
        let pageStart = page * appsPerPage
        let pageEnd = min(pageStart + appsPerPage, groups[groupIndex].appIds.count)
        
        guard pageStart < groups[groupIndex].appIds.count else { return }
        
        // Extract items on this page
        var pageItems = Array(groups[groupIndex].appIds[pageStart..<pageEnd])
        
        // Separate apps and voids
        let apps = pageItems.filter { $0 != AppGroup.voidId }
        let voidCount = pageItems.count - apps.count
        
        // Rebuild page: apps first, then voids
        pageItems = apps + Array(repeating: AppGroup.voidId, count: voidCount)
        
        // Replace in the main array
        for (i, item) in pageItems.enumerated() {
            groups[groupIndex].appIds[pageStart + i] = item
        }
    }
    
    /// Remove trailing voids from the end of the array
    private func cleanupTrailingVoids(groupIndex: Int) {
        while !groups[groupIndex].appIds.isEmpty && groups[groupIndex].appIds.last == AppGroup.voidId {
            groups[groupIndex].appIds.removeLast()
        }
    }
    
    /// Swap two apps by their indices within a group
    func swapAppsInGroup(_ appId: UUID, withAppAtIndex targetIndex: Int, in group: AppGroup) {
        guard let groupIndex = groups.firstIndex(where: { $0.id == group.id }) else { return }
        
        // Work with actual app IDs only (filter out any voids)
        var actualAppIds = groups[groupIndex].appIds.filter { $0 != AppGroup.voidId }
        
        guard let currentIndex = actualAppIds.firstIndex(of: appId) else { return }
        guard targetIndex >= 0 && targetIndex < actualAppIds.count else { return }
        
        // Don't swap with itself
        if currentIndex == targetIndex {
            return
        }
        
        // Perform the swap
        actualAppIds.swapAt(currentIndex, targetIndex)
        
        // Update the group
        groups[groupIndex].appIds = actualAppIds
        
        saveData()
    }
    
    // MARK: - Import/Export
    
    /// Export current settings to a file
    func exportSettings() -> Bool {
        let data = LauncherData(
            groups: groups,
            ungroupedAppIds: ungroupedAppIds,
            allApps: allApps
        )
        return dataManager.exportData(data)
    }
    
    /// Import settings from a file
    func importSettings() -> Bool {
        guard let importedData = dataManager.importData() else {
            return false
        }
        
        // Get fresh apps from disk to validate imported data
        let freshApps = AppScanner.scanApplications()
        
        // Match imported apps with current system apps by path
        var pathToFreshApp: [String: AppItem] = [:]
        for app in freshApps {
            pathToFreshApp[app.path] = app
        }
        
        // Build mapping from imported app IDs to fresh app IDs
        var idMapping: [UUID: UUID] = [:]
        for importedApp in importedData.allApps {
            if let freshApp = pathToFreshApp[importedApp.path] {
                idMapping[importedApp.id] = freshApp.id
            }
        }
        
        // Update all apps to fresh versions
        self.allApps = freshApps
        
        // Map group app IDs to new IDs, keeping only valid ones
        self.groups = importedData.groups.map { group in
            var updatedGroup = group
            updatedGroup.appIds = group.appIds.compactMap { idMapping[$0] }
            return updatedGroup
        }
        
        // Map ungrouped app IDs
        let mappedUngrouped = Set(importedData.ungroupedAppIds.compactMap { idMapping[$0] })
        
        // Find apps that aren't in any group
        let groupedAppIds = Set(groups.flatMap { $0.appIds })
        
        // Start with mapped ungrouped, add any fresh apps not in groups
        var ungrouped = Array(mappedUngrouped)
        for app in freshApps {
            if !groupedAppIds.contains(app.id) && !ungrouped.contains(app.id) {
                ungrouped.append(app.id)
            }
        }
        self.ungroupedAppIds = ungrouped
        
        saveData()
        return true
    }
}
