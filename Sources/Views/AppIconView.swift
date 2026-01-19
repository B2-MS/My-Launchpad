import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// View for a single app icon
struct AppIconView: View {
    let app: AppItem
    let isSelected: Bool
    let isEditMode: Bool
    let groups: [AppGroup]
    var iconScale: CGFloat = 1.0
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onAddToGroup: (AppGroup) -> Void
    let onCreateNewGroup: () -> Void
    
    @State private var isHovering = false
    @State private var icon: NSImage?
    @State private var isDragging = false
    
    // Scaled sizes
    private var iconSize: CGFloat { 48 * iconScale }
    private var frameWidth: CGFloat { 80 * iconScale }
    private var frameHeight: CGFloat { 90 * iconScale }
    private var nameWidth: CGFloat { 70 * iconScale }
    private var nameHeight: CGFloat { 30 * iconScale }
    private var fontSize: CGFloat { 11 * iconScale }
    
    var body: some View {
        VStack(spacing: 4 * iconScale) {
            ZStack(alignment: .topTrailing) {
                // App icon
                Group {
                    if let icon = icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "app.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: iconSize, height: iconSize)
                .shadow(color: .black.opacity(0.2), radius: isHovering ? 4 : 2, y: isHovering ? 2 : 1)
                .scaleEffect(isHovering ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovering)
                
                // Selection checkmark
                if isEditMode {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.5))
                            .frame(width: 20, height: 20)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(x: 4, y: -4)
                }
            }
            
            // App name
            Text(app.name)
                .font(.system(size: fontSize))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: nameWidth, height: nameHeight)
                .foregroundColor(isHovering ? .primary : .secondary)
        }
        .frame(width: frameWidth, height: frameHeight)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            onTap()
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    onLongPress()
                }
        )
        .onAppear {
            // Load icon asynchronously
            DispatchQueue.global(qos: .userInitiated).async {
                let loadedIcon = app.getIcon()
                DispatchQueue.main.async {
                    self.icon = loadedIcon
                }
            }
        }
        .opacity(isEditMode && !isSelected ? 0.7 : 1.0)
        .opacity(isDragging ? 0.5 : 1.0)
        .draggable(app.id.uuidString) {
            // Drag preview
            VStack(spacing: 4) {
                if let icon = icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                }
                Text(app.name)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
            .padding(8)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(8)
        }
        .contextMenu {
            Button {
                onCreateNewGroup()
            } label: {
                Label("Create New Group", systemImage: "folder.badge.plus")
            }
            
            if !groups.isEmpty {
                Divider()
                
                Menu {
                    ForEach(groups.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { group in
                        Button {
                            onAddToGroup(group)
                        } label: {
                            Label(group.name, systemImage: "folder")
                        }
                    }
                } label: {
                    Label("Add to Group", systemImage: "folder")
                }
            }
        }
    }
}

/// Preview provider
struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView(
            app: AppItem(name: "Sample App", path: "/Applications/Safari.app"),
            isSelected: false,
            isEditMode: false,
            groups: [],
            onTap: {},
            onLongPress: {},
            onAddToGroup: { _ in },
            onCreateNewGroup: {}
        )
    }
}
