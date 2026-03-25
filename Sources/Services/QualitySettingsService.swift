import Foundation

struct QualitySettings: Codable {
    var preset: Preset
    var customBitRate: Int
    var customFPS: Int
    var resolution: Resolution
    var audioEnabled: Bool
    var audioBitRate: Int

    enum Preset: String, Codable, CaseIterable {
        case auto = "Auto"
        case low = "Low (720p 2Mbps)"
        case medium = "Medium (1080p 5Mbps)"
        case high = "High (1080p 10Mbps)"
        case ultra = "Ultra (4K 25Mbps)"
        case custom = "Custom"
    }

    enum Resolution: String, Codable, CaseIterable {
        case r720p = "720p"
        case r1080p = "1080p"
        case r1440p = "1440p"
        case r4k = "4K"

        var size: (width: Int, height: Int) {
            switch self {
            case .r720p: return (1280, 720)
            case .r1080p: return (1920, 1080)
            case .r1440p: return (2560, 1440)
            case .r4k: return (3840, 2160)
            }
        }
    }

    static let `default` = QualitySettings(
        preset: .medium,
        customBitRate: 5000,
        customFPS: 30,
        resolution: .r1080p,
        audioEnabled: true,
        audioBitRate: 128
    )
}

final class QualitySettingsService: ObservableObject {
    static let shared = QualitySettingsService()

    @Published var settings: QualitySettings = .default

    private let key = "qualitySettings"

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
              let decoded = try? JSONDecoder().decode(QualitySettings.self, from: data) else {
            return
        }
        settings = decoded
    }

    var effectiveBitRate: Int {
        switch settings.preset {
        case .auto: return 5000
        case .low: return 2000
        case .medium: return 5000
        case .high: return 10000
        case .ultra: return 25000
        case .custom: return settings.customBitRate
        }
    }

    var effectiveFPS: Int {
        switch settings.preset {
        case .auto: return 30
        case .low: return 24
        case .medium: return 30
        case .high: return 30
        case .ultra: return 60
        case .custom: return settings.customFPS
        }
    }

    var estimatedBandwidth: String {
        let kbps = effectiveBitRate
        if kbps >= 1000 {
            return "\(kbps / 1000) Mbps"
        }
        return "\(kbps) kbps"
    }
}
