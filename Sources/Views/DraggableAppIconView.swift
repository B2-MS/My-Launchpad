import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// A draggable app icon that can receive drops from other apps to create groups
struct DraggableAppIconView: View {
    let app: AppItem
    let isSelected: Bool
    let isEditMode: Bool
    let groups: [AppGroup]
    @Binding var draggedAppId: UUID?
    
    let onTap: (NSEvent.ModifierFlags) -> Void
    let onLongPress: () -> Void
    let onAddToGroup: (AppGroup) -> Void
    let onCreateNewGroup: () -> Void
    let onDropOntoApp: (UUID) -> Void
    let onReorderApp: (UUID) -> Void
    
    @State private var isHovered = false
    @State private var isDropTargeted = false
    @State private var isReorderTarget = false
    @State private var loadedIcon: NSImage? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            iconView
            nameView
        }
        .padding(8)
        .background(backgroundView)
        .overlay(borderView)
        .onHover { hovering in
            isHovered = hovering
        }
        .gesture(
            TapGesture()
                .onEnded { _ in
                    onTap(NSEvent.modifierFlags)
                }
        )
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress()
        }
        .draggable(app.id.uuidString) {
            dragPreview
        }
        .dropDestination(for: String.self) { items, _ in
            handleDrop(items: items)
        } isTargeted: { targeted in
            isDropTargeted = targeted
        }
        .contextMenu {
            contextMenuContent
        }
        .onAppear {
            loadIcon()
        }
    }
    
    // MARK: - Subviews
    
    private var iconView: some View {
        ZStack(alignment: .topTrailing) {
            if let icon = loadedIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            } else {
                placeholderIcon
            }
            
            if isEditMode && isSelected {
                selectionCheckmark
            }
        }
    }
    
    private var placeholderIcon: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 48, height: 48)
            .overlay(
                Image(systemName: "app.fill")
                    .foregroundColor(.gray)
            )
    }
    
    private var selectionCheckmark: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 18, height: 18)
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            )
            .offset(x: 6, y: -6)
    }
    
    private var nameView: some View {
        Text(app.name)
            .font(.system(size: 10))
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(width: 70)
            .foregroundColor(.primary)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(backgroundColor)
    }
    
    private var backgroundColor: Color {
        if isDropTargeted {
            return Color.purple.opacity(0.3)
        } else if isReorderTarget {
            return Color.blue.opacity(0.2)
        } else if isHovered {
            return Color.gray.opacity(0.15)
        }
        return Color.clear
    }
    
    private var borderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isDropTargeted ? Color.purple : (isReorderTarget ? Color.blue : Color.clear), lineWidth: 2)
    }
    
    private var dragPreview: some View {
        VStack(spacing: 4) {
            if let icon = loadedIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            }
            Text(app.name)
                .font(.system(size: 10))
                .lineLimit(1)
        }
        .padding(8)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            onCreateNewGroup()
        } label: {
            Label("Create New Group", systemImage: "folder.badge.plus")
        }
        
        if !groups.isEmpty {
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
    
    // MARK: - Helper Methods
    
    private func loadIcon() {
        DispatchQueue.global(qos: .userInitiated).async {
            let icon = app.getIcon()
            DispatchQueue.main.async {
                self.loadedIcon = icon
            }
        }
    }
    
    private func handleDrop(items: [String]) -> Bool {
        guard let uuidString = items.first,
              let droppedId = UUID(uuidString: uuidString),
              droppedId != app.id else {
            return false
        }
        
        // Skip if it's a group being dragged (starts with "group:")
        if uuidString.hasPrefix("group:") {
            return false
        }
        
        // Default behavior: create a new group when dropping app onto app
        // Hold Option key to reorder instead
        if NSEvent.modifierFlags.contains(.option) {
            onReorderApp(droppedId)
        } else {
            onDropOntoApp(droppedId)
        }
        return true
    }
}
