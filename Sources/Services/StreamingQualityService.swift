import Foundation
import VideoToolbox
import Network

// MARK: - Streaming Quality Service

final class StreamingQualityService: ObservableObject {
    static let shared = StreamingQualityService()
    
    @Published var currentBitrate: Int = 5000000
    @Published var frameRate: Double = 30.0
    @Published var resolution: Resolution = .hd1080p
    @Published var isLowLatencyMode: Bool = true
    
    enum Resolution: String, CaseIterable {
        case hd720p = "720p"
        case hd1080p = "1080p"
        case uhd4k = "4K"
        
        var width: Int {
            switch self {
            case .hd720p: return 1280
            case .hd1080p: return 1920
            case .uhd4k: return 3840
            }
        }
        
        var height: Int {
            switch self {
            case .hd720p: return 720
            case .hd1080p: return 1080
            case .uhd4k: return 2160
            }
        }
    }
    
    private init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let bitrate = UserDefaults.standard.object(forKey: "cast_bitrate") as? Int {
            currentBitrate = bitrate
        }
        if let fps = UserDefaults.standard.object(forKey: "cast_framerate") as? Double {
            frameRate = fps
        }
        if let res = UserDefaults.standard.string(forKey: "cast_resolution"), let resolution = Resolution(rawValue: res) {
            self.resolution = resolution
        }
        isLowLatencyMode = UserDefaults.standard.bool(forKey: "cast_lowLatency")
    }
    
    func setBitrate(_ bitrate: Int) {
        currentBitrate = bitrate
        UserDefaults.standard.set(bitrate, forKey: "cast_bitrate")
    }
    
    func setResolution(_ resolution: Resolution) {
        self.resolution = resolution
        UserDefaults.standard.set(resolution.rawValue, forKey: "cast_resolution")
    }
}

// MARK: - Network Optimization Service

final class NetworkOptimizationService: ObservableObject {
    static let shared = NetworkOptimizationService()
    
    @Published var connectionQuality: ConnectionQuality = .good
    @Published var isWiFi: Bool = true
    
    enum ConnectionQuality {
        case excellent, good, fair, poor
    }
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isWiFi = path.usesInterfaceType(.wifi)
                self?.updateConnectionQuality(path: path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updateConnectionQuality(path: NWPath) {
        if path.status == .satisfied {
            if path.isExpensive {
                connectionQuality = .fair
            } else {
                connectionQuality = .good
            }
        } else {
            connectionQuality = .poor
        }
    }
    
    func shouldLowerQuality() -> Bool {
        return connectionQuality == .poor || connectionQuality == .fair
    }
}
