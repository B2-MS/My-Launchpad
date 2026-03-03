import SwiftUI
import AppKit

/// A compact group icon that shows a preview of apps inside (like iOS folders)
/// Supports collapsed state (just folder icon) and expanded state (configurable grid preview)
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
    let onChangeTileSize: ((GroupTileSize) -> Void)?
    var isDropTarget: Bool = false
    
    @State private var isHovering = false
    @State private var isAppDropTarget = false
    @State private var isGroupDropTarget = false
    @State private var previewIcons: [NSImage] = []
    
    // Constants
    private let standardWidth: CGFloat = 120
    private let standardHeight: CGFloat = 135
    private let tileSpacing: CGFloat = 8
    
    // Base sizes (at scale 1.0) - accounts for spacing when spanning multiple tiles
    private var baseWidth: CGFloat {
        let span = CGFloat(group.tileSize.gridSpanWidth)
        return span * standardWidth + (span - 1) * tileSpacing
    }
    private var baseHeight: CGFloat {
        let span = CGFloat(group.tileSize.gridSpanHeight)
        return span * standardHeight + (span - 1) * tileSpacing
    }
    private var baseIconSize: CGFloat { baseWidth - 36 }  // Leave margin for name
    private var baseIconHeight: CGFloat { baseHeight - 51 }  // Leave room for name + margin
    private var baseFolderIconSize: CGFloat { 42 }
    private var baseMiniIconSize: CGFloat {
        // Calculate icon size based on available space and columns
        let iconAreaWidth = baseIconSize - 8  // Padding
        let iconAreaHeight = baseIconHeight - 8
        let cols = CGFloat(group.tileSize.columns)
        let rows = CGFloat(group.tileSize.rows)
        let iconSpacing: CGFloat = 4
        let maxWidthPerIcon = (iconAreaWidth - (cols - 1) * iconSpacing) / cols
        let maxHeightPerIcon = (iconAreaHeight - (rows - 1) * iconSpacing) / rows
        return min(maxWidthPerIcon, maxHeightPerIcon)
    }
    private var baseNameWidth: CGFloat { baseWidth - 15 }
    private var baseNameHeight: CGFloat { 35 }
    
    // Scaled sizes
    private var scaledWidth: CGFloat { baseWidth * scale }
    private var scaledHeight: CGFloat { baseHeight * scale }
    private var scaledIconSize: CGFloat { baseIconSize * scale }
    private var scaledIconHeight: CGFloat { baseIconHeight * scale }
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
        .draggable(dragId)
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
            .frame(width: scaledIconSize, height: scaledIconHeight)
            
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
        .frame(width: scaledIconSize, height: scaledIconHeight)
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
        VStack(spacing: 4 * scale) {
            ForEach(0..<group.tileSize.rows, id: \.self) { row in
                HStack(spacing: 4 * scale) {
                    ForEach(0..<group.tileSize.columns, id: \.self) { col in
                        miniIconSlot(at: row * group.tileSize.columns + col)
                    }
                }
            }
        }
        .padding(4 * scale)
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
        .frame(width: scaledIconSize, height: scaledIconHeight)
    }
    
    private var dropTargetBorder: some View {
        RoundedRectangle(cornerRadius: 16 * scale)
            .stroke(
                isDropTarget ? Color.blue : (isGroupDropTarget ? Color.blue : (isAppDropTarget ? Color.purple : Color.clear)),
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
        let iconCount = group.tileSize.appCount
        DispatchQueue.global(qos: .userInitiated).async {
            let icons = apps.prefix(iconCount).map { $0.getIcon() }
            DispatchQueue.main.async {
                self.previewIcons = icons
            }
        }
    }
    
    // MARK: - Drop Handling
    
    private func handleDrop(items: [String]) -> Bool {
        // Write to file for debugging
        let debugMsg = "handleDrop called with: \(items)\n"
        if let data = debugMsg.data(using: .utf8) {
            let fileHandle = FileHandle(forWritingAtPath: "/tmp/drop_debug.log")
            if fileHandle == nil {
                FileManager.default.createFile(atPath: "/tmp/drop_debug.log", contents: data)
            } else {
                fileHandle?.seekToEndOfFile()
                fileHandle?.write(data)
                fileHandle?.closeFile()
            }
        }
        
        print("DEBUG: GroupIconView.handleDrop called with items: \(items)")
        guard let uuidString = items.first else {
            print("DEBUG: No items in drop")
            return false
        }
        
        // Check if this is a group being dropped (for reordering)
        if uuidString.hasPrefix("group:") {
            let groupIdString = String(uuidString.dropFirst(6))
            print("DEBUG: Group drop - extracted ID: \(groupIdString)")
            if let groupId = UUID(uuidString: groupIdString), groupId != group.id {
                print("DEBUG: Reordering group \(groupId) to position of \(group.id)")
                onReorderGroup(groupId)
                isGroupDropTarget = false
                isAppDropTarget = false
                return true
            }
            print("DEBUG: Group drop - same group or invalid UUID")
            return false
        } else {
            // It's an app ID - add to this group
            if let appId = UUID(uuidString: uuidString) {
                print("DEBUG: Adding app \(appId) to group \(group.id)")
                onDropApp(appId)
                isGroupDropTarget = false
                isAppDropTarget = false
                return true
            }
            print("DEBUG: Invalid app UUID: \(uuidString)")
            return false
        }
    }
}
