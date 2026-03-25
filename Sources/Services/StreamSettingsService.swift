import Foundation

struct StreamSettings: Codable {
    var platform: Platform
    var streamKey: String
    var serverURL: String
    var videoBitrate: Int
    var audioBitrate: Int
    var encoder: Encoder
    var latencyMode: LatencyMode
    var autoRestartOnDisconnect: Bool
    var recordWhileStreaming: Bool

    enum Platform: String, Codable, CaseIterable {
        case youtube = "YouTube Live"
        case twitch = "Twitch"
        case custom = "Custom RTMP"

        var defaultServerURL: String {
            switch self {
            case .youtube: return "rtmp://a.rtmp.youtube.com/live2"
            case .twitch: return "rtmp://live.twitch.tv/app"
            case .custom: return ""
            }
        }
    }

    enum Encoder: String, Codable, CaseIterable {
        case software = "Software (x264)"
        case hardware = "Hardware (VideoToolbox)"
        case appleProRes = "Apple ProRes"

        var displayName: String { rawValue }
    }

    enum LatencyMode: String, Codable, CaseIterable {
        case normal = "Normal"
        case low = "Low Latency"
        case ultraLow = "Ultra Low Latency"
    }

    static let `default` = StreamSettings(
        platform: .youtube,
        streamKey: "",
        serverURL: "rtmp://a.rtmp.youtube.com/live2",
        videoBitrate: 4500,
        audioBitrate: 128,
        encoder: .hardware,
        latencyMode: .normal,
        autoRestartOnDisconnect: true,
        recordWhileStreaming: false
    )
}

final class StreamSettingsService: ObservableObject {
    static let shared = StreamSettingsService()

    @Published var settings: StreamSettings = .default

    private let key = "streamSettings"

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
              let decoded = try? JSONDecoder().decode(StreamSettings.self, from: data) else {
            return
        }
        settings = decoded
    }

    func selectPlatform(_ platform: StreamSettings.Platform) {
        settings.platform = platform
        if settings.serverURL.isEmpty || isDefaultURL(settings.serverURL) {
            settings.serverURL = platform.defaultServerURL
        }
    }

    private func isDefaultURL(_ url: String) -> Bool {
        StreamSettings.Platform.allCases.contains { $0.defaultServerURL == url }
    }
}
