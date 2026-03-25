import Foundation

enum MediaSource: Identifiable, Codable {
    case screen
    case window(UUID)
    case application(UUID)
    case camera(UUID)

    var id: UUID {
        switch self {
        case .screen: return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        case .window(let id): return id
        case .application(let id): return id
        case .camera(let id): return id
        }
    }

    var displayName: String {
        switch self {
        case .screen: return "Screen"
        case .window: return "Window"
        case .application: return "Application"
        case .camera: return "Camera"
        }
    }
}

struct MediaSourceInfo: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: MediaSourceType
    var thumbnail: Data?
    var isActive: Bool

    enum MediaSourceType: String, Codable {
        case screen
        case window
        case application
        case camera
    }
}

final class MediaSourceService: ObservableObject {
    static let shared = MediaSourceService()

    @Published var sources: [MediaSourceInfo] = []
    @Published var selectedSource: MediaSource?

    func refreshSources() {
        // Get windows
        let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
        var windowSources: [MediaSourceInfo] = []

        for app in runningApps {
            let source = MediaSourceInfo(
                id: app.processIdentifier,
                name: app.localizedName ?? "Unknown",
                type: .application,
                isActive: app.isActive
            )
            windowSources.append(source)
        }

        DispatchQueue.main.async {
            self.sources = windowSources
        }
    }
}
