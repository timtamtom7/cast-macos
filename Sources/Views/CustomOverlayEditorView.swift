import SwiftUI

struct CustomOverlayEditorView: View {
    @StateObject private var overlayService = CustomOverlayService.shared
    @State private var selectedOverlay: CustomOverlay?
    @State private var showCreateSheet = false
    @State private var newOverlayName = ""

    var body: some View {
        HSplitView {
            // Overlay list
            VStack(spacing: 0) {
                HStack {
                    Text("Overlays")
                        .font(.headline)
                    Spacer()
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(overlayService.overlays) { overlay in
                            overlayRow(overlay)
                            Divider()
                        }
                    }
                }
            }
            .frame(width: 200)

            // Overlay editor
            if let overlay = selectedOverlay {
                overlayEditorView(overlay)
            } else {
                VStack {
                    Image(systemName: "square.on.square")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select an overlay to edit")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert("New Overlay", isPresented: $showCreateSheet) {
            TextField("Name", text: $newOverlayName)
            Button("Cancel", role: .cancel) {}
            Button("Create") {
                let overlay = overlayService.createOverlay(name: newOverlayName)
                selectedOverlay = overlay
                newOverlayName = ""
            }
        }
    }

    @ViewBuilder
    private func overlayRow(_ overlay: CustomOverlay) -> some View {
        HStack {
            Image(systemName: overlay.isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(overlay.isEnabled ? .accentColor : .secondary)
            Text(overlay.name)
                .font(.system(size: 13))
            Spacer()
            Text("\(overlay.elements.count) elements")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(selectedOverlay?.id == overlay.id ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedOverlay = overlay
        }
        .contextMenu {
            Button("Delete") {
                overlayService.deleteOverlay(id: overlay.id)
                if selectedOverlay?.id == overlay.id {
                    selectedOverlay = nil
                }
            }
        }
    }

    @ViewBuilder
    private func overlayEditorView(_ overlay: CustomOverlay) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(overlay.name)
                    .font(.headline)
                Spacer()
                Toggle("Enabled", isOn: Binding(
                    get: { overlay.isEnabled },
                    set: { newValue in
                        var updated = overlay
                        updated.isEnabled = newValue
                        overlayService.updateOverlay(updated)
                    }
                ))
            }
            .padding()

            Divider()

            // Element list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(overlay.elements) { element in
                        elementRow(element)
                    }
                }
                .padding()
            }

            Divider()

            // Add element toolbar
            HStack {
                ForEach(OverlayElement.ElementType.allCases, id: \.self) { type in
                    Button(action: { addElement(type: type, to: overlay) }) {
                        Image(systemName: iconFor(type))
                    }
                    .buttonStyle(.bordered)
                    .help(type.rawValue)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func elementRow(_ element: OverlayElement) -> some View {
        HStack {
            Image(systemName: iconFor(element.type))
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(element.type.rawValue)
                    .font(.system(size: 13, weight: .medium))
                if !element.content.isEmpty {
                    Text(element.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text("(\(Int(element.position.x)), \(Int(element.position.y)))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }

    private func iconFor(_ type: OverlayElement.ElementType) -> String {
        switch type {
        case .text: return "textformat"
        case .image: return "photo"
        case .clock: return "clock"
        case .webcam: return "camera"
        case .shape: return "square.on.square"
        }
    }

    private func addElement(type: OverlayElement.ElementType, to overlay: CustomOverlay) {
        let content: String
        switch type {
        case .text: content = "Your text here"
        case .image: content = ""
        case .clock: content = "HH:mm:ss"
        case .webcam: content = ""
        case .shape: content = ""
        }

        let element = OverlayElement(
            type: type,
            position: CodablePoint(x: 50, y: 50),
            size: CodableSize(width: 200, height: 100),
            content: content
        )
        overlayService.addElement(element, to: overlay.id)
    }
}
