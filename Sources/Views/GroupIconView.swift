import SwiftUI
import AppKit

/// A compact group icon that shows a preview of apps inside (like iOS folders)
/// Supports collapsed state (just folder icon) and expanded state (2x2 preview)
struct GroupIconView: View {
    let group: AppGroup
    let apps: [AppItem]
    let isEditMode: Bool
    let isCollapsed: Bool
    let scale: CGFloat
    let onTap: () -> Void
    let onDropApp: (UUID) -> Void
    let onReorderGroup: (UUID) -> Void
    let onToggleCollapse: () -> Void
    
    @State private var isHovering = false
    @State private var isAppDropTarget = false
    @State private var isGroupDropTarget = false
    @State private var previewIcons: [NSImage] = []
    
    // Base sizes (at scale 1.0)
    private var baseWidth: CGFloat { 120 }
    private var baseHeight: CGFloat { 135 }
    private var baseIconSize: CGFloat { 84 }
    private var baseFolderIconSize: CGFloat { 42 }
    private var baseMiniIconSize: CGFloat { 42 }
    private var baseNameWidth: CGFloat { 105 }
    private var baseNameHeight: CGFloat { 35 }
    
    // Scaled sizes
    private var scaledWidth: CGFloat { baseWidth * scale }
    private var scaledHeight: CGFloat { baseHeight * scale }
    private var scaledIconSize: CGFloat { baseIconSize * scale }
    private var scaledFolderIconSize: CGFloat { baseFolderIconSize * scale }
    private var scaledMiniIconSize: CGFloat { baseMiniIconSize * scale }
    private var scaledNameWidth: CGFloat { baseNameWidth * scale }
    private var scaledNameHeight: CGFloat { baseNameHeight * scale }
    
    private var dragId: String {
        "group:" + group.id.uuidString
    }
    
    var body: some View {
        VStack(spacing: 4 * scale) {
            folderIconView
            groupNameView
        }
        .frame(width: scaledWidth, height: scaledHeight)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            onTap()
        }
        .onAppear {
            loadPreviewIcons()
        }
        .onChange(of: apps.map { $0.id }) { _ in
            loadPreviewIcons()
        }
        .draggable(dragId) {
            dragPreview
        }
        .dropDestination(for: String.self) { items, _ in
            handleDrop(items: items)
        } isTargeted: { targeted in
            if targeted {
                // We'll determine the type when the drop actually happens
                isAppDropTarget = true
            } else {
                isAppDropTarget = false
                isGroupDropTarget = false
            }
        }
    }
    
    // MARK: - Folder Icon
    
    private var folderIconView: some View {
        ZStack {
            // Glass background with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 18 * scale)
                    .fill(.thickMaterial)
                
                // Strong color gradient overlay
                RoundedRectangle(cornerRadius: 18 * scale)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(isCollapsed ? 0.5 : 0.35),
                                Color.blue.opacity(isCollapsed ? 0.3 : 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Bright highlight stroke
                RoundedRectangle(cornerRadius: 18 * scale)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.7), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .frame(width: scaledIconSize, height: scaledIconSize)
            
            if isCollapsed {
                collapsedContent
            } else {
                expandedContent
            }
            
            // Collapse/Expand button (visible on hover)
            if isHovering || isEditMode {
                collapseButton
            }
        }
        .frame(width: scaledIconSize, height: scaledIconSize)
        .overlay(dropTargetBorder)
        .shadow(color: .purple.opacity(0.4), radius: isHovering ? 16 : 10, y: isHovering ? 8 : 4)
        .scaleEffect(isHovering ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovering)
        .animation(.easeInOut(duration: 0.2), value: isCollapsed)
    }
    
    private var collapsedContent: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "folder.fill")
                .font(.system(size: scaledFolderIconSize))
                .foregroundColor(.purple)
            
            if apps.count > 0 {
                Text("\(apps.count)")
                    .font(.system(size: 12 * scale, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5 * scale)
                    .padding(.vertical, 3 * scale)
                    .background(Color.purple)
                    .cornerRadius(10 * scale)
                    .offset(x: 10 * scale, y: -6 * scale)
            }
        }
    }
    
    private var expandedContent: some View {
        VStack(spacing: 5 * scale) {
            HStack(spacing: 5 * scale) {
                miniIconSlot(at: 0)
                miniIconSlot(at: 1)
            }
            HStack(spacing: 5 * scale) {
                miniIconSlot(at: 2)
                miniIconSlot(at: 3)
            }
        }
    }
    
    private var collapseButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onToggleCollapse) {
                    Image(systemName: isCollapsed ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                        .font(.system(size: 14 * scale))
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.purple))
                }
                .buttonStyle(.plain)
                .offset(x: 6 * scale, y: -6 * scale)
            }
            Spacer()
        }
        .frame(width: scaledIconSize, height: scaledIconSize)
    }
    
    private var dropTargetBorder: some View {
        RoundedRectangle(cornerRadius: 16 * scale)
            .stroke(
                isGroupDropTarget ? Color.blue : (isAppDropTarget ? Color.purple : Color.clear),
                lineWidth: 3 * scale
            )
    }
    
    // MARK: - Group Name
    
    private var groupNameView: some View {
        Text(group.name)
            .font(.system(size: 13 * scale))
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(width: scaledNameWidth, height: scaledNameHeight)
            .foregroundColor(isHovering ? .primary : .secondary)
    }
    
    // MARK: - Drag Preview
    
    private var dragPreview: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.3))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "folder.fill")
                        .foregroundColor(.purple)
                )
            Text(group.name)
                .font(.system(size: 11))
                .lineLimit(1)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
    
    // MARK: - Mini Icons
    
    @ViewBuilder
    private func miniIconSlot(at index: Int) -> some View {
        if index < apps.count {
            // Load icon directly from app to ensure it's always current
            let app = apps[index]
            Image(nsImage: app.getIcon())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: scaledMiniIconSize, height: scaledMiniIconSize)
                .cornerRadius(6 * scale)
        } else {
            RoundedRectangle(cornerRadius: 6 * scale)
                .fill(Color.gray.opacity(0.3))
                .frame(width: scaledMiniIconSize, height: scaledMiniIconSize)
        }
    }
    
    private func loadPreviewIcons() {
        // Keep for backwards compatibility but icons now load directly
        DispatchQueue.global(qos: .userInitiated).async {
            let icons = apps.prefix(4).map { $0.getIcon() }
            DispatchQueue.main.async {
                self.previewIcons = icons
            }
        }
    }
    
    // MARK: - Drop Handling
    
    private func handleDrop(items: [String]) -> Bool {
        guard let uuidString = items.first else {
            return false
        }
        
        // Check if this is a group being dropped (for reordering)
        if uuidString.hasPrefix("group:") {
            let groupIdString = String(uuidString.dropFirst(6))
            if let groupId = UUID(uuidString: groupIdString), groupId != group.id {
                print("Reordering group \(groupId) to position of \(group.id)")
                onReorderGroup(groupId)
                isGroupDropTarget = false
                isAppDropTarget = false
                return true
            }
            return false
        } else {
            // It's an app ID - add to this group
            if let appId = UUID(uuidString: uuidString) {
                print("Adding app \(appId) to group \(group.id)")
                onDropApp(appId)
                isGroupDropTarget = false
                isAppDropTarget = false
                return true
            }
            return false
        }
    }
}
