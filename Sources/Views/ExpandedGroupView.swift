import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// An expanded group popup overlay (like iOS folder popup) with pagination
struct ExpandedGroupView: View {
    let group: AppGroup
    let apps: [AppItem]
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
    
    @State private var editedName: String = ""
    @State private var currentPage: Int = 0
    @State private var dropTargetAppId: UUID? = nil
    @State private var dropInsertIndex: Int? = nil
    @FocusState private var isTextFieldFocused: Bool
    
    private let appsPerPage = 16
    private let gridColumns = 4
    
    private var totalPages: Int {
        max(1, Int(ceil(Double(apps.count) / Double(appsPerPage))))
    }
    
    private var currentPageApps: [AppItem] {
        let startIndex = currentPage * appsPerPage
        let endIndex = min(startIndex + appsPerPage, apps.count)
        guard startIndex < apps.count else { return [] }
        return Array(apps[startIndex..<endIndex])
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
            contentView
            if totalPages > 1 {
                paginationView
            }
        }
        .frame(width: 500, height: totalPages > 1 ? 560 : 508)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(headerColor.opacity(0.3), lineWidth: 1)
        )
    }
    
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
        .padding(.vertical, 4)
        .background(headerColor)
    }
    
    // MARK: - Content
    
    private var contentView: some View {
        Group {
            if apps.isEmpty {
                emptyStateView
            } else {
                paginatedGridView
            }
        }
    }
    
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
            // Grid for current page
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(currentPageApps) { app in
                    pageAppIcon(for: app)
                }
                
                // Fill empty slots to maintain grid structure
                ForEach(0..<(appsPerPage - currentPageApps.count), id: \.self) { _ in
                    Color.clear
                        .frame(width: 100, height: 110)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .padding(.bottom, 16)
            .frame(height: 470)
            
            // Drop zone for moving apps to different pages
            if totalPages > 1 {
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        pageDropZone(targetPage: currentPage - 1, label: "← Previous")
                    }
                    if currentPage < totalPages - 1 {
                        pageDropZone(targetPage: currentPage + 1, label: "Next →")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }
    
    private func pageAppIcon(for app: AppItem) -> some View {
        let appIndex = apps.firstIndex(where: { $0.id == app.id }) ?? 0
        
        return HStack(spacing: 0) {
            // Left drop zone for insert
            Rectangle()
                .fill(dropInsertIndex == appIndex ? Color.purple.opacity(0.3) : Color.clear)
                .frame(width: 8)
                .dropDestination(for: String.self) { items, _ in
                    handleInsertDrop(items: items, atIndex: appIndex)
                } isTargeted: { targeted in
                    dropInsertIndex = targeted ? appIndex : nil
                }
            
            AppIconView(
                app: app,
                isSelected: false,
                isEditMode: false,
                groups: allGroups.filter { $0.id != group.id },
                iconScale: 1.25,
                onTap: { onAppTap(app) },
                onLongPress: { },
                onAddToGroup: { targetGroup in onAddAppToGroup(app, targetGroup) },
                onCreateNewGroup: { onCreateNewGroupWithApp(app) }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(dropTargetAppId == app.id ? Color.purple : Color.clear, lineWidth: 3)
            )
            .dropDestination(for: String.self) { items, _ in
                handleSwapDrop(items: items, withApp: app)
            } isTargeted: { targeted in
                dropTargetAppId = targeted ? app.id : nil
            }
            
            // Right drop zone for insert (only for last item in row or last item)
            if (appIndex + 1) % gridColumns == 0 || appIndex == currentPageApps.count - 1 {
                Rectangle()
                    .fill(dropInsertIndex == appIndex + 1 ? Color.purple.opacity(0.3) : Color.clear)
                    .frame(width: 8)
                    .dropDestination(for: String.self) { items, _ in
                        handleInsertDrop(items: items, atIndex: appIndex + 1)
                    } isTargeted: { targeted in
                        dropInsertIndex = targeted ? appIndex + 1 : nil
                    }
            }
        }
        .draggable(app.id.uuidString) {
            AppDragPreview(app: app)
        }
        .contextMenu {
            appContextMenu(for: app)
        }
    }
    
    private func handleSwapDrop(items: [String], withApp targetApp: AppItem) -> Bool {
        guard let uuidString = items.first,
              let draggedAppId = UUID(uuidString: uuidString),
              draggedAppId != targetApp.id,
              let reorder = onReorderAppsInGroup else {
            return false
        }
        
        // Swap: move dragged app to target app's position
        if let targetIndex = apps.firstIndex(where: { $0.id == targetApp.id }) {
            reorder(draggedAppId, targetIndex)
        }
        dropTargetAppId = nil
        return true
    }
    
    private func handleInsertDrop(items: [String], atIndex insertIndex: Int) -> Bool {
        guard let uuidString = items.first,
              let draggedAppId = UUID(uuidString: uuidString),
              let reorder = onReorderAppsInGroup else {
            return false
        }
        
        // Calculate absolute index based on current page
        let absoluteIndex = currentPage * appsPerPage + insertIndex
        reorder(draggedAppId, absoluteIndex)
        dropInsertIndex = nil
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
    
    private func pageDropZone(targetPage: Int, label: String) -> some View {
        Text(label)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
            .dropDestination(for: String.self) { items, _ in
                guard let uuidString = items.first,
                      let appId = UUID(uuidString: uuidString),
                      let app = apps.first(where: { $0.id == appId }) else {
                    return false
                }
                moveAppToPage(app, page: targetPage)
                return true
            } isTargeted: { isTargeted in
                // Could add visual feedback here
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentPage = targetPage
                }
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
                                  let app = apps.first(where: { $0.id == appId }) else {
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
    
    private func moveAppToPage(_ app: AppItem, page: Int) {
        guard apps.contains(where: { $0.id == app.id }) else { return }
        
        // Calculate the target index (beginning of target page)
        let targetIndex = page * appsPerPage
        
        // Use the reorder callback if available
        if let reorder = onReorderAppsInGroup {
            reorder(app.id, targetIndex)
        }
        
        // Navigate to target page
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
