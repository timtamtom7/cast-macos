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
    private var startTime: Date?

    func startRecording() {
        state = .preparing

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.state = .recording
            self.startTime = Date()
            self.startTimer()
        }
    }

    func pauseRecording() {
        state = .paused
        stopTimer()
    }

    func resumeRecording() {
        state = .recording
        startTimer()
    }

    func stopRecording() {
        state = .stopped
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
        guard let start = startTime else { return }
        elapsedTime = Date().timeIntervalSince(start)
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
