import Foundation

enum StreamState {
    case idle
    case connecting
    case live
    case reconnecting
    case ended
}

struct StreamStats: Codable {
    var currentViewers: Int
    var totalViews: Int
    var peakViewers: Int
    var bitrate: Int
    var droppedFrames: Int
    var fps: Double

    var healthScore: Int {
        if droppedFrames > 100 { return 0 }
        if droppedFrames > 50 { return 1 }
        if droppedFrames > 10 { return 2 }
        return 3
    }
}

final class StreamService: ObservableObject {
    static let shared = StreamService()

    @Published var state: StreamState = .idle
    @Published var stats = StreamStats(currentViewers: 0, totalViews: 0, peakViewers: 0, bitrate: 0, droppedFrames: 0, fps: 0)
    @Published var streamKeyVisible = false

    private var reconnectTimer: Timer?

    func startStream() {
        state = .connecting
        // Simulate connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.state = .live
            self.startStatsPolling()
        }
    }

    func stopStream() {
        state = .ended
        reconnectTimer?.invalidate()
    }

    func reconnect() {
        state = .reconnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.state = .live
        }
    }

    private func startStatsPolling() {
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }

    private func updateStats() {
        stats.currentViewers = Int.random(in: 0...50)
        stats.totalViews += stats.currentViewers
        stats.peakViewers = max(stats.peakViewers, stats.currentViewers)
        stats.bitrate = Int.random(in: 4000...5000)
        stats.droppedFrames = Int.random(in: 0...5)
        stats.fps = 60.0
    }
}
