import SwiftUI

struct StreamSettingsView: View {
    @StateObject private var streamService = StreamSettingsService.shared
    @State private var showStreamKey = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stream Settings")
                .font(.headline)

            Form {
                // Platform
                Picker("Platform", selection: Binding(
                    get: { streamService.settings.platform },
                    set: { streamService.selectPlatform($0) }
                )) {
                    ForEach(StreamSettings.Platform.allCases, id: \.self) { platform in
                        Text(platform.rawValue).tag(platform)
                    }
                }
                .labelsHidden()

                // Server URL
                TextField("Server URL", text: $streamService.settings.serverURL)
                    .textFieldStyle(.roundedBorder)

                // Stream key
                HStack {
                    if showStreamKey {
                        TextField("Stream Key", text: $streamService.settings.streamKey)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("Stream Key", text: $streamService.settings.streamKey)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button(action: { showStreamKey.toggle() }) {
                        Image(systemName: showStreamKey ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                }

                Divider()

                // Video settings
                HStack {
                    Text("Video Bitrate:")
                    Stepper("\(streamService.settings.videoBitrate) kbps",
                            value: $streamService.settings.videoBitrate, in: 1000...10000, step: 500)
                }

                // Audio settings
                Stepper("Audio Bitrate: \(streamService.settings.audioBitrate) kbps",
                        value: $streamService.settings.audioBitrate, in: 64...320, step: 32)

                // Encoder
                Picker("Encoder", selection: $streamService.settings.encoder) {
                    ForEach(StreamSettings.Encoder.allCases, id: \.self) { encoder in
                        Text(encoder.displayName).tag(encoder)
                    }
                }
                .labelsHidden()

                Divider()

                // Latency
                Picker("Latency", selection: $streamService.settings.latencyMode) {
                    ForEach(StreamSettings.LatencyMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .labelsHidden()

                Toggle("Auto-restart on disconnect", isOn: $streamService.settings.autoRestartOnDisconnect)
                Toggle("Record while streaming", isOn: $streamService.settings.recordWhileStreaming)
            }

            Button("Save Settings") {
                streamService.save()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
