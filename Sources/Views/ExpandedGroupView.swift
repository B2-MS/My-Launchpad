import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Scroll Wheel Handler for Page Navigation

struct ScrollWheelModifier: ViewModifier {
    let onScrollLeft: () -> Void
    let onScrollRight: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                ScrollWheelCaptureView(
                    onScrollLeft: onScrollLeft,
                    onScrollRight: onScrollRight
                )
            )
    }
}

struct ScrollWheelCaptureView: NSViewRepresentable {
    let onScrollLeft: () -> Void
    let onScrollRight: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.onScrollLeft = onScrollLeft
        context.coordinator.onScrollRight = onScrollRight
        
        // Add local event monitor for scroll wheel
        context.coordinator.monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            context.coordinator.handleScroll(event: event)
            return event
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onScrollLeft = onScrollLeft
        context.coordinator.onScrollRight = onScrollRight
    }
    
    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        if let monitor = coordinator.monitor {
            NSEvent.removeMonitor(monitor)
            coordinator.monitor = nil
        }
    }
    
    class Coordinator {
        var onScrollLeft: (() -> Void)?
        var onScrollRight: (() -> Void)?
        var monitor: Any?
        
        private var scrollAccumulator: CGFloat = 0
        private var lastScrollTime: Date = Date()
        private let threshold: CGFloat = 30
        
        func handleScroll(event: NSEvent) {
            let now = Date()
            
            // Reset accumulator if it's been a while since last scroll
            if now.timeIntervalSince(lastScrollTime) > 0.3 {
                scrollAccumulator = 0
            }
            lastScrollTime = now
            
            // Use scrollingDeltaX for horizontal scroll
            scrollAccumulator += event.scrollingDeltaX
            
            if scrollAccumulator > threshold {
                scrollAccumulator = 0
                DispatchQueue.main.async {
                    self.onScrollRight?()
                }
            } else if scrollAccumulator < -threshold {
                scrollAccumulator = 0
                DispatchQueue.main.async {
                    self.onScrollLeft?()
                }
            }
        }
    }
}

/// An expanded group popup overlay (like iOS folder popup) with pagination
struct ExpandedGroupView: View {
    let group: AppGroup
    let appLookup: [UUID: AppItem]  // Dictionary to look up apps by ID
    let allGroups: [AppGroup]
    let isEditingName: Bool
    let headerColor: Color
    
    let onClose: () -> Void
    let onRename: (String) -> Void
    let onStartRename: () -> Void
    let onAppTap: (AppItem) -> Void
    let onAddAppToGroup: (AppItem, AppGroup) -> Void
    let onCreateNewGroupWithApp: (AppItem) -> Void
    let onRemoveAppFromGroup: (AppItem) -> Void
    let onReorderAppsInGroup: ((UUID, Int) -> Void)?
    let onSwapAppsInGroup: ((UUID, Int) -> Void)?
    
    @State private var editedName: String = ""
    @State private var currentPage: Int = 0
    @State private var dropTargetAppId: UUID? = nil
    @State private var dropInsertIndex: Int? = nil
    @State private var isLeftEdgeTargeted: Bool = false
    @State private var isRightEdgeTargeted: Bool = false
    @State private var swipeAccumulator: CGFloat = 0
    @State private var edgeHoverTimer: Timer? = nil
    @FocusState private var isTextFieldFocused: Bool
    
    private let appsPerPage = 16
    private let gridColumns = 4
    
    /// All slot IDs for the group (includes voids)
    private var allSlotIds: [UUID] {
        group.appIds
    }
    
    /// Total number of pages based on all slots
    private var totalPages: Int {
        max(1, Int(ceil(Double(allSlotIds.count) / Double(appsPerPage))))
    }
    
    /// Apps for the current page - sorted so apps come first, then voids (keeps apps contiguous)
    private var currentPageAppIds: [UUID] {
        let startIndex = currentPage * appsPerPage
        let endIndex = min(startIndex + appsPerPage, allSlotIds.count)
        guard startIndex < allSlotIds.count else { return [] }
        
        let pageSlots = Array(allSlotIds[startIndex..<endIndex])
        
        // Sort: real apps first (contiguous), then voids at the end
        let apps = pageSlots.filter { !AppGroup.isVoid($0) }
        let voids = pageSlots.filter { AppGroup.isVoid($0) }
        
        return apps + voids
    }
    
    /// Number of real apps on current page
    private var appsOnCurrentPage: Int {
        currentPageAppIds.filter { !AppGroup.isVoid($0) }.count
    }
    
    /// Actual apps in the group (for counting)
    private var actualApps: [AppItem] {
        group.actualAppIds.compactMap { appLookup[$0] }
    }
    
    private let columns = [
        GridItem(.fixed(100), spacing: 8),
        GridItem(.fixed(100), spacing: 8),
        GridItem(.fixed(100), spacing: 8),
        GridItem(.fixed(100), spacing: 8)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            // Content with edge drop zones
            HStack(spacing: 0) {
                // Left edge drop zone
                if totalPages > 1 {
                    edgeDropZone(isLeft: true, enabled: currentPage > 0)
                }
                
                // Main grid content
                mainGridContent
                
                // Right edge drop zone
                if totalPages > 1 {
                    edgeDropZone(isLeft: false, enabled: currentPage < totalPages - 1)
                }
            }
            
            if totalPages > 1 {
                paginationView
            }
        }
        .frame(width: totalPages > 1 ? 580 : 500, height: totalPages > 1 ? 580 : 540)
        .background(
            ZStack {
                // Frosted glass material base
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thickMaterial)
                
                // Color tint gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                headerColor.opacity(0.15),
                                Color.purple.opacity(0.1),
                                Color.blue.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: headerColor.opacity(0.3), radius: 40, y: 15)
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.7), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
    
    // MARK: - Main Grid Content
    
    private var mainGridContent: some View {
        Group {
            if actualApps.isEmpty {
                emptyStateView
            } else {
                paginatedGridView
            }
        }
        .frame(width: 500)
    }
    
    // MARK: - Edge Drop Zone
    
    private func edgeDropZone(isLeft: Bool, enabled: Bool) -> some View {
        let isTargeted = isLeft ? isLeftEdgeTargeted : isRightEdgeTargeted
        let targetPage = isLeft ? currentPage - 1 : currentPage + 1
        
        return VStack {
            Spacer()
            
            // Invisible drop zone - this triggers page navigation, NOT a drop
            Rectangle()
                .fill(Color.clear)
                .frame(width: 36, height: 350)
                .contentShape(Rectangle())
                .onDrop(of: [.text], isTargeted: Binding(
                    get: { isLeft ? isLeftEdgeTargeted : isRightEdgeTargeted },
                    set: { newValue in
                        if isLeft {
                            isLeftEdgeTargeted = newValue
                        } else {
                            isRightEdgeTargeted = newValue
                        }
                        
                        // When drag enters the edge zone, start a timer to flip the page
                        if newValue && enabled {
                            edgeHoverTimer?.invalidate()
                            edgeHoverTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                                DispatchQueue.main.async {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        currentPage = targetPage
                                    }
                                }
                            }
                        } else {
                            // Cancel timer if drag leaves
                            edgeHoverTimer?.invalidate()
                            edgeHoverTimer = nil
                        }
                    }
                )) { providers in
                    // Don't actually drop here - just return false so the drag continues
                    // The page has already flipped, user can drop on the grid
                    return false
                }
            
            Spacer()
        }
        .frame(width: 40)
    }
    
    // Remove the old handleEdgeDrop function since we're not dropping on edges anymore
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            if isEditingName {
                TextField("Group name", text: $editedName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        onRename(editedName)
                    }
                    .onAppear {
                        editedName = group.name
                        isTextFieldFocused = true
                    }
            } else {
                Text(group.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .onTapGesture {
                        onStartRename()
                    }
            }
            
            Spacer()
            
            // Page indicator in header
            if totalPages > 1 {
                Text("\(currentPage + 1)/\(totalPages)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
            }
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 48)
        .background(
            ZStack {
                // Glass material with color tint
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                // Color overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [headerColor.opacity(0.8), headerColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Top highlight
                VStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 1)
                    Spacer()
                }
            }
        )
    }
    
    // MARK: - Content
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "app.badge.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No apps in this group")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Drag apps here to add them")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    private var paginatedGridView: some View {
        VStack(spacing: 0) {
            // Grid for current page - apps are contiguous, voids at the end
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(currentPageAppIds.enumerated()), id: \.element) { localIndex, slotId in
                    if AppGroup.isVoid(slotId) {
                        // Void slot - droppable empty space (appears after all apps)
                        voidSlotView(localIndex: localIndex)
                    } else if let app = appLookup[slotId] {
                        // Render an app icon
                        pageAppIcon(for: app, localIndex: localIndex)
                    }
                }
                
                // Fill remaining empty slots to maintain grid structure (for drops)
                ForEach(0..<(appsPerPage - currentPageAppIds.count), id: \.self) { emptyIndex in
                    let dropIndex = currentPageAppIds.count + emptyIndex
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 100, height: 110)
                        .contentShape(Rectangle())
                        .dropDestination(for: String.self) { items, _ in
                            handleInsertDrop(items: items, atLocalIndex: dropIndex)
                        } isTargeted: { targeted in
                            dropInsertIndex = targeted ? dropIndex : nil
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .padding(.bottom, 16)
            .frame(height: 500)
            .modifier(ScrollWheelModifier(
                onScrollLeft: {
                    if currentPage < totalPages - 1 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentPage += 1
                        }
                    }
                },
                onScrollRight: {
                    if currentPage > 0 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentPage -= 1
                        }
                    }
                }
            ))
        }
    }
    
    /// View for a void (empty) slot - can receive drops
    private func voidSlotView(localIndex: Int) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 100, height: 110)
            .contentShape(Rectangle())
            .dropDestination(for: String.self) { items, _ in
                handleInsertDrop(items: items, atLocalIndex: localIndex)
            } isTargeted: { targeted in
                dropInsertIndex = targeted ? localIndex : nil
            }
    }
    
    private func pageAppIcon(for app: AppItem, localIndex: Int) -> some View {
        
        return HStack(spacing: 0) {
            // Left drop zone for insert
            Rectangle()
                .fill(Color.clear)
                .frame(width: 8)
                .contentShape(Rectangle())
                .dropDestination(for: String.self) { items, _ in
                    handleInsertDrop(items: items, atLocalIndex: localIndex)
                } isTargeted: { targeted in
                    dropInsertIndex = targeted ? localIndex : nil
                }
            
            AppIconView(
                app: app,
                isSelected: false,
                isEditMode: false,
                groups: allGroups.filter { $0.id != group.id },
                iconScale: 1.25,
                isInGroup: true,
                onTap: { onAppTap(app) },
                onLongPress: { },
                onAddToGroup: { targetGroup in onAddAppToGroup(app, targetGroup) },
                onCreateNewGroup: { onCreateNewGroupWithApp(app) },
                onRemoveFromGroup: { onRemoveAppFromGroup(app) }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(dropTargetAppId == app.id ? Color.purple : Color.clear, lineWidth: 3)
            )
            .dropDestination(for: String.self) { items, _ in
                // Drop ON an app = insert at that app's position (push it and others forward)
                handleInsertDrop(items: items, atLocalIndex: localIndex)
            } isTargeted: { targeted in
                dropTargetAppId = targeted ? app.id : nil
            }
            
            // Right drop zone for insert (only for last item in row or last app on page)
            if (localIndex + 1) % gridColumns == 0 || localIndex == appsOnCurrentPage - 1 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 8)
                    .contentShape(Rectangle())
                    .dropDestination(for: String.self) { items, _ in
                        handleInsertDrop(items: items, atLocalIndex: localIndex + 1)
                    } isTargeted: { targeted in
                        dropInsertIndex = targeted ? localIndex + 1 : nil
                    }
            }
        }
        .draggable(app.id.uuidString) {
            AppDragPreview(app: app)
        }
    }
    
    private func handleInsertDrop(items: [String], atLocalIndex localIndex: Int) -> Bool {
        guard let uuidString = items.first,
              let draggedAppId = UUID(uuidString: uuidString),
              let reorder = onReorderAppsInGroup else {
            return false
        }
        
        // Calculate absolute index based on current page
        let absoluteIndex = currentPage * appsPerPage + localIndex
        reorder(draggedAppId, absoluteIndex)
        dropInsertIndex = nil
        dropTargetAppId = nil
        return true
    }
    
    @ViewBuilder
    private func appContextMenu(for app: AppItem) -> some View {
        Button {
            onCreateNewGroupWithApp(app)
        } label: {
            Label("Move to New Group", systemImage: "folder.badge.plus")
        }
        
        if allGroups.filter({ $0.id != group.id }).count > 0 {
            Menu {
                ForEach(allGroups.filter { $0.id != group.id }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { targetGroup in
                    Button {
                        onAddAppToGroup(app, targetGroup)
                    } label: {
                        Label(targetGroup.name, systemImage: "folder")
                    }
                }
            } label: {
                Label("Move to Group", systemImage: "folder")
            }
        }
        
        if totalPages > 1 {
            Menu {
                ForEach(0..<totalPages, id: \.self) { page in
                    if page != currentPage {
                        Button {
                            moveAppToPage(app, page: page)
                        } label: {
                            Label("Page \(page + 1)", systemImage: "square.grid.3x3")
                        }
                    }
                }
            } label: {
                Label("Move to Page", systemImage: "arrow.left.arrow.right")
            }
        }
        
        Divider()
        
        Button {
            onRemoveAppFromGroup(app)
        } label: {
            Label("Remove from Group", systemImage: "minus.circle")
        }
    }
    
    // MARK: - Pagination
    
    private var paginationView: some View {
        HStack(spacing: 8) {
            // Previous button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentPage = max(0, currentPage - 1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(currentPage > 0 ? .purple : .gray.opacity(0.5))
            }
            .buttonStyle(.plain)
            .disabled(currentPage == 0)
            
            // Page dots
            HStack(spacing: 6) {
                ForEach(0..<totalPages, id: \.self) { page in
                    Circle()
                        .fill(page == currentPage ? Color.purple : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentPage = page
                            }
                        }
                        .dropDestination(for: String.self) { items, _ in
                            guard let uuidString = items.first,
                                  let appId = UUID(uuidString: uuidString),
                                  let app = appLookup[appId] else {
                                return false
                            }
                            moveAppToPage(app, page: page)
                            return true
                        } isTargeted: { _ in }
                }
            }
            
            // Next button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentPage = min(totalPages - 1, currentPage + 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(currentPage < totalPages - 1 ? .purple : .gray.opacity(0.5))
            }
            .buttonStyle(.plain)
            .disabled(currentPage >= totalPages - 1)
        }
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Actions
    
    /// Move an app to a specific page (used by context menu)
    private func moveAppToPage(_ app: AppItem, page: Int) {
        guard let currentAppIndex = allSlotIds.firstIndex(of: app.id) else { return }
        
        let currentAppPage = currentAppIndex / appsPerPage
        
        // Don't move if already on the target page
        if currentAppPage == page {
            return
        }
        
        // Calculate target index - place at the end of the target page
        let targetIndex: Int
        if page > currentAppPage {
            // Moving forward: place at end of target page
            let endOfPage = min((page + 1) * appsPerPage, allSlotIds.count)
            targetIndex = endOfPage
        } else {
            // Moving backward: place at end of target page
            targetIndex = (page + 1) * appsPerPage
        }
        
        if let reorder = onReorderAppsInGroup {
            reorder(app.id, targetIndex)
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            currentPage = page
        }
    }
}

/// Drag preview for an app
struct AppDragPreview: View {
    let app: AppItem
    @State private var loadedIcon: NSImage? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            if let icon = loadedIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "app.fill")
                            .foregroundColor(.gray)
                    )
            }
            Text(app.name)
                .font(.system(size: 10))
                .lineLimit(1)
        }
        .padding(8)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            loadedIcon = app.getIcon()
        }
    }
}
