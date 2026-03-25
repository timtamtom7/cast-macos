import Foundation
import CoreGraphics

struct MirrorSettings: Codable {
    var displayMode: DisplayMode
    var showCursor: Bool
    var showDesktopIcons: Bool
    var showNotificationCenter: Bool
    var includeAudio: Bool
    var useOptimalResolution: Bool

    enum DisplayMode: String, Codable, CaseIterable {
        case window = "Window"
        case fullScreen = "Full Screen"
        case portion = "Portion"

        var displayName: String { rawValue }
    }

    static let `default` = MirrorSettings(
        displayMode: .fullScreen,
        showCursor: true,
        showDesktopIcons: true,
        showNotificationCenter: false,
        includeAudio: true,
        useOptimalResolution: true
    )
}

final class MirrorSettingsService: ObservableObject {
    static let shared = MirrorSettingsService()

    @Published var settings: MirrorSettings = .default

    private let key = "mirrorSettings"

    init() {
        loadSettings()
    }

    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(MirrorSettings.self, from: data) else {
            return
        }
        settings = decoded
    }
}
