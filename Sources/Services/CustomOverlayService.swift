import Foundation
import AppKit

struct CustomOverlay: Identifiable, Codable {
    let id: UUID
    var name: String
    var elements: [OverlayElement]
    var isEnabled: Bool

    init(id: UUID = UUID(), name: String, elements: [OverlayElement] = [], isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.elements = elements
        self.isEnabled = isEnabled
    }
}

struct OverlayElement: Identifiable, Codable {
    let id: UUID
    var type: ElementType
    var position: CodablePoint
    var size: CodableSize
    var content: String
    var style: ElementStyle

    enum ElementType: String, Codable, CaseIterable {
        case text = "Text"
        case image = "Image"
        case clock = "Clock"
        case webcam = "Webcam"
        case shape = "Shape"
    }

    init(id: UUID = UUID(), type: ElementType, position: CodablePoint = .zero, size: CodableSize = CodableSize(width: 200, height: 100), content: String = "", style: ElementStyle = ElementStyle()) {
        self.id = id
        self.type = type
        self.position = position
        self.size = size
        self.content = content
        self.style = style
    }
}

struct CodablePoint: Codable {
    var x: Double
    var y: Double

    static let zero = CodablePoint(x: 0, y: 0)

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

struct CodableSize: Codable {
    var width: Double
    var height: Double

    var cgSize: CGSize { CGSize(width: width, height: height) }
}

struct ElementStyle: Codable {
    var fontName: String?
    var fontSize: Int
    var textColor: String
    var backgroundColor: String?
    var borderRadius: Double
    var opacity: Double
    var zIndex: Int

    init(fontName: String? = nil, fontSize: Int = 16, textColor: String = "#FFFFFF", backgroundColor: String? = nil, borderRadius: Double = 0, opacity: Double = 1, zIndex: Int = 0) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderRadius = borderRadius
        self.opacity = opacity
        self.zIndex = zIndex
    }
}

final class CustomOverlayService: ObservableObject {
    static let shared = CustomOverlayService()

    @Published var overlays: [CustomOverlay] = []
    @Published var activeOverlay: CustomOverlay?

    private let key = "customOverlays"

    init() {
        loadOverlays()
    }

    func createOverlay(name: String) -> CustomOverlay {
        let overlay = CustomOverlay(name: name)
        overlays.append(overlay)
        saveOverlays()
        return overlay
    }

    func deleteOverlay(id: UUID) {
        overlays.removeAll { $0.id == id }
        if activeOverlay?.id == id {
            activeOverlay = nil
        }
        saveOverlays()
    }

    func updateOverlay(_ overlay: CustomOverlay) {
        if let index = overlays.firstIndex(where: { $0.id == overlay.id }) {
            overlays[index] = overlay
            saveOverlays()
        }
    }

    func addElement(_ element: OverlayElement, to overlayId: UUID) {
        if let index = overlays.firstIndex(where: { $0.id == overlayId }) {
            overlays[index].elements.append(element)
            saveOverlays()
        }
    }

    func removeElement(_ elementId: UUID, from overlayId: UUID) {
        if let index = overlays.firstIndex(where: { $0.id == overlayId }) {
            overlays[index].elements.removeAll { $0.id == elementId }
            saveOverlays()
        }
    }

    private func loadOverlays() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CustomOverlay].self, from: data) else {
            return
        }
        overlays = decoded
    }

    private func saveOverlays() {
        if let data = try? JSONEncoder().encode(overlays) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
