import SwiftUI
import AppKit

/// A standalone app tile that appears at the same level as groups
/// Same size as GroupIconView for visual consistency
struct StandaloneAppTileView: View {
    let app: AppItem
    let isEditMode: Bool
    let scale: CGFloat
    let onTap: () -> Void
    let onUnpin: () -> Void
    let onMoveToGroup: (AppGroup) -> Void
    let groups: [AppGroup]
    
    @State private var isHovering = false
    @State private var isDropTarget = false
    @State private var loadedIcon: NSImage? = nil
    
    // Base sizes (matching GroupIconView)
    private var baseWidth: CGFloat { 120 }
    private var baseHeight: CGFloat { 135 }
    private var baseIconSize: CGFloat { 84 }
    private var baseNameWidth: CGFloat { 105 }
    private var baseNameHeight: CGFloat { 35 }
    
    // Scaled sizes
    private var scaledWidth: CGFloat { baseWidth * scale }
    private var scaledHeight: CGFloat { baseHeight * scale }
    private var scaledIconSize: CGFloat { baseIconSize * scale }
    private var scaledNameWidth: CGFloat { baseNameWidth * scale }
    private var scaledNameHeight: CGFloat { baseNameHeight * scale }
    
    private var dragId: String {
        "standaloneApp:" + app.id.uuidString
    }
    
    var body: some View {
        VStack(spacing: 4 * scale) {
            iconView
            appNameView
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
            loadIcon()
        }
        .draggable(dragId) {
            dragPreview
        }
        .contextMenu {
            contextMenuContent
        }
    }
    
    // MARK: - Icon View
    
    private var iconView: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                // Glass background matching GroupIconView style
                ZStack {
                    RoundedRectangle(cornerRadius: 18 * scale)
                        .fill(.thickMaterial)
                    
                    // Subtle blue gradient for standalone apps (different from purple groups)
                    RoundedRectangle(cornerRadius: 18 * scale)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.2),
                                    Color.cyan.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Highlight stroke
                    RoundedRectangle(cornerRadius: 18 * scale)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .frame(width: scaledIconSize, height: scaledIconSize)
                
                // App icon
                if let icon = loadedIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: scaledIconSize * 0.7, height: scaledIconSize * 0.7)
                } else {
                    ProgressView()
                        .frame(width: scaledIconSize * 0.7, height: scaledIconSize * 0.7)
                }
            }
            .frame(width: scaledIconSize, height: scaledIconSize)
            
            // Unpin button in edit mode
            if isEditMode {
                Button {
                    onUnpin()
                } label: {
                    Image(systemName: "pin.slash.fill")
                        .font(.system(size: 10 * scale, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22 * scale, height: 22 * scale)
                        .background(
                            Circle()
                                .fill(Color.orange)
                                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        )
                }
                .buttonStyle(.plain)
                .offset(x: 4 * scale, y: -4 * scale)
                .help("Unpin from Grid")
            }
        }
        .scaleEffect(isHovering ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovering)
        .shadow(color: .black.opacity(0.2), radius: isHovering ? 8 : 4, x: 0, y: 2)
    }
    
    // MARK: - App Name
    
    private var appNameView: some View {
        Text(app.name)
            .font(.system(size: 11 * scale, weight: .medium))
            .foregroundColor(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(width: scaledNameWidth, height: scaledNameHeight, alignment: .top)
    }
    
    // MARK: - Drag Preview
    
    private var dragPreview: some View {
        VStack(spacing: 4) {
            if let icon = loadedIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
            }
            Text(app.name)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(8)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
    
    // MARK: - Context Menu
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            onTap()
        } label: {
            Label("Open", systemImage: "arrow.up.forward.app")
        }
        
        Divider()
        
        Button {
            onUnpin()
        } label: {
            Label("Unpin from Grid", systemImage: "pin.slash")
        }
        
        if !groups.isEmpty {
            Menu("Move to Group") {
                ForEach(groups) { group in
                    Button(group.name) {
                        onMoveToGroup(group)
                    }
                }
            }
        }
        
        Divider()
        
        Button {
            NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: app.path)])
        } label: {
            Label("Show in Finder", systemImage: "folder")
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadIcon() {
        DispatchQueue.global(qos: .userInitiated).async {
            let icon = app.getIcon()
            DispatchQueue.main.async {
                self.loadedIcon = icon
            }
        }
    }
}
