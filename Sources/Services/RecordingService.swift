import Foundation

enum RecordingState {
    case idle
    case preparing
    case recording
    case paused
    case stopped
}

struct RecordingSettings: Codable {
    var saveLocation: String
    var fileFormat: FileFormat
    var includeCursor: Bool
    var includeAudio: Bool
    var recordSystemAudio: Bool
    var recordMicrophone: Bool
    var countdownSeconds: Int
    var maxDuration: TimeInterval?
    var splitInterval: TimeInterval?

    enum FileFormat: String, Codable, CaseIterable {
        case mp4 = "MP4"
        case mov = "MOV"
        case mkv = "MKV"

        var fileExtension: String { rawValue.lowercased() }

        var codec: String {
            switch self {
            case .mp4: return "h264"
            case .mov: return "hevc"
            case .mkv: return "h264"
            }
        }
    }

    static let `default` = RecordingSettings(
        saveLocation: NSSearchPathForDirectoriesInDomains(.moviesDirectory, .userDomainMask, true).first ?? "",
        fileFormat: .mp4,
        includeCursor: true,
        includeAudio: true,
        recordSystemAudio: true,
        recordMicrophone: false,
        countdownSeconds: 3,
        maxDuration: nil,
        splitInterval: nil
    )
}

final class RecordingService: ObservableObject {
    static let shared = RecordingService()

    @Published var state: RecordingState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var fileSize: Int64 = 0
    @Published var settings: RecordingSettings = .default

    private var timer: Timer?
    private var accumulatedTime: TimeInterval = 0
    private var sessionStartTime: Date?

    func startRecording() {
        state = .preparing

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.state = .recording
            self.sessionStartTime = Date()
            self.startTimer()
        }
    }

    func pauseRecording() {
        state = .paused
        stopTimer()
        if let start = sessionStartTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }
        sessionStartTime = nil
    }

    func resumeRecording() {
        state = .recording
        sessionStartTime = Date()
        startTimer()
    }

    func stopRecording() {
        state = .stopped
        if let start = sessionStartTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }
        sessionStartTime = nil
        accumulatedTime = 0
        stopTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateElapsed()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateElapsed() {
        var total = accumulatedTime
        if let start = sessionStartTime {
            total += Date().timeIntervalSince(start)
        }
        elapsedTime = total
    }

    func formattedElapsed() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let tenths = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }

    func formattedFileSize() -> String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}
