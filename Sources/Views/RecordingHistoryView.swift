import SwiftUI

struct RecordingHistoryView: View {
    @StateObject private var storage = RecordingStorageService.shared
    @State private var searchQuery = ""
    @State private var sortBy: SortOption = .dateRecorded

    enum SortOption: String, CaseIterable {
        case dateRecorded = "Date Recorded"
        case duration = "Duration"
        case fileSize = "File Size"
        case title = "Title"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                TextField("Search recordings...", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)

                Spacer()

                Picker("Sort", selection: $sortBy) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .labelsHidden()
            }
            .padding()

            Divider()

            if storage.recordings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No recordings yet")
                        .font(.headline)
                    Text("Your screen recordings will appear here")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredRecordings) { recording in
                            recordingRow(recording)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var filteredRecordings: [RecordedFile] {
        var recordings = storage.recordings

        if !searchQuery.isEmpty {
            recordings = recordings.filter {
                $0.title.localizedCaseInsensitiveContains(searchQuery) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
            }
        }

        switch sortBy {
        case .dateRecorded:
            recordings.sort { $0.recordedAt > $1.recordedAt }
        case .duration:
            recordings.sort { $0.duration > $1.duration }
        case .fileSize:
            recordings.sort { $0.fileSize > $1.fileSize }
        case .title:
            recordings.sort { $0.title < $1.title }
        }

        return recordings
    }

    @ViewBuilder
    private func recordingRow(_ recording: RecordedFile) -> some View {
        HStack(spacing: 12) {
            // Thumbnail
            Group {
                if let thumbnailPath = recording.thumbnailPath,
                   let image = NSImage(contentsOfFile: thumbnailPath) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Color(NSColor.controlBackgroundColor)
                        Image(systemName: "video.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 120, height: 68)
            .cornerRadius(6)

            VStack(alignment: .leading, spacing: 4) {
                Text(recording.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label(recording.formattedDuration, systemImage: "clock")
                    Label(recording.formattedFileSize, systemImage: "doc")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if !recording.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(recording.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }

            Spacer()

            // Actions
            Menu {
                Button("Show in Finder") {
                    NSWorkspace.shared.selectFile(recording.filePath, inFileViewerRootedAtPath: "")
                }
                Button("Rename") {
                    // rename
                }
                Button("Add Tags") {
                    // add tags
                }
                Divider()
                Button("Delete", role: .destructive) {
                    storage.deleteRecording(recording)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)

            Button(action: { openRecording(recording) }) {
                Image(systemName: "play.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func openRecording(_ recording: RecordedFile) {
        NSWorkspace.shared.open(URL(fileURLWithPath: recording.filePath))
    }
}
