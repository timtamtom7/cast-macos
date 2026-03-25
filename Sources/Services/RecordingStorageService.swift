import Foundation

struct RecordedFile: Identifiable, Codable {
    let id: UUID
    let filePath: String
    let title: String
    let duration: TimeInterval
    let fileSize: Int64
    let recordedAt: Date
    var thumbnailPath: String?
    var tags: [String]
    var notes: String

    init(filePath: String, title: String, duration: TimeInterval, fileSize: Int64, recordedAt: Date = Date(), thumbnailPath: String? = nil, tags: [String] = [], notes: String = "") {
        self.id = UUID()
        self.filePath = filePath
        self.title = title
        self.duration = duration
        self.fileSize = fileSize
        self.recordedAt = recordedAt
        self.thumbnailPath = thumbnailPath
        self.tags = tags
        self.notes = notes
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}

final class RecordingStorageService: ObservableObject {
    static let shared = RecordingStorageService()

    @Published var recordings: [RecordedFile] = []

    private let key = "recordedFiles"

    init() {
        loadRecordings()
    }

    func addRecording(_ recording: RecordedFile) {
        recordings.insert(recording, at: 0)
        saveRecordings()
    }

    func deleteRecording(_ recording: RecordedFile) {
        try? FileManager.default.removeItem(atPath: recording.filePath)
        if let thumbnailPath = recording.thumbnailPath {
            try? FileManager.default.removeItem(atPath: thumbnailPath)
        }
        recordings.removeAll { $0.id == recording.id }
        saveRecordings()
    }

    func updateRecording(_ recording: RecordedFile) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
            saveRecordings()
        }
    }

    private func loadRecordings() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([RecordedFile].self, from: data) else {
            return
        }
        recordings = decoded
    }

    private func saveRecordings() {
        if let data = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
