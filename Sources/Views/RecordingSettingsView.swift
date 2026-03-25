import SwiftUI

struct RecordingSettingsView: View {
    @StateObject private var recordingService = RecordingService.shared
    @State private var showFolderPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recording Settings")
                .font(.headline)

            Form {
                // Save location
                HStack {
                    Text("Save Location:")
                    Text(recordingService.settings.saveLocation)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Button("Choose...") {
                        chooseSaveLocation()
                    }
                }

                // File format
                Picker("Format", selection: $recordingService.settings.fileFormat) {
                    ForEach(RecordingSettings.FileFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .labelsHidden()

                Divider()

                // Recording options
                Toggle("Include Cursor", isOn: $recordingService.settings.includeCursor)
                Toggle("Record System Audio", isOn: $recordingService.settings.recordSystemAudio)
                Toggle("Record Microphone", isOn: $recordingService.settings.recordMicrophone)

                Divider()

                // Countdown
                Stepper("Countdown: \(recordingService.settings.countdownSeconds)s",
                        value: $recordingService.settings.countdownSeconds, in: 0...10)

                Divider()

                // Advanced
                Toggle("Split Recording", isOn: Binding(
                    get: { recordingService.settings.splitInterval != nil },
                    set: { enabled in
                        recordingService.settings.splitInterval = enabled ? 300 : nil
                    }
                ))

                if recordingService.settings.splitInterval != nil {
                    Stepper("Split every \(Int(recordingService.settings.splitInterval! / 60)) min",
                            value: Binding(
                                get: { recordingService.settings.splitInterval ?? 300 },
                                set: { recordingService.settings.splitInterval = $0 }
                            ), in: 60...1800, step: 60)
                }

                Toggle("Maximum Duration", isOn: Binding(
                    get: { recordingService.settings.maxDuration != nil },
                    set: { enabled in
                        recordingService.settings.maxDuration = enabled ? 3600 : nil
                    }
                ))

                if recordingService.settings.maxDuration != nil {
                    Stepper("\(Int((recordingService.settings.maxDuration ?? 3600) / 60)) min max",
                            value: Binding(
                                get: { recordingService.settings.maxDuration ?? 3600 },
                                set: { recordingService.settings.maxDuration = $0 }
                            ), in: 60...14400, step: 60)
                }
            }

            Button("Save Settings") {
                saveSettings()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func chooseSaveLocation() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else { return }
        recordingService.settings.saveLocation = url.path
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(recordingService.settings) {
            UserDefaults.standard.set(data, forKey: "recordingSettings")
        }
    }
}
