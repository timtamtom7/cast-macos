import SwiftUI

struct QualitySettingsView: View {
    @StateObject private var qualityService = QualitySettingsService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Streaming Quality")
                .font(.headline)

            Form {
                Picker("Preset", selection: $qualityService.settings.preset) {
                    ForEach(QualitySettings.Preset.allCases, id: \.self) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .labelsHidden()

                if qualityService.settings.preset == .custom {
                    Stepper("Bitrate: \(qualityService.settings.customBitRate) kbps",
                            value: $qualityService.settings.customBitRate, in: 500...25000, step: 500)

                    Stepper("FPS: \(qualityService.settings.customFPS)",
                            value: $qualityService.settings.customFPS, in: 15...60, step: 5)
                }

                Picker("Resolution", selection: $qualityService.settings.resolution) {
                    ForEach(QualitySettings.Resolution.allCases, id: \.self) { res in
                        Text(res.rawValue).tag(res)
                    }
                }
                .labelsHidden()

                Toggle("Include Audio", isOn: $qualityService.settings.audioEnabled)

                if qualityService.settings.audioEnabled {
                    Stepper("Audio Bitrate: \(qualityService.settings.audioBitRate) kbps",
                            value: $qualityService.settings.audioBitRate, in: 64...320, step: 64)
                }
            }

            Divider()

            HStack {
                Text("Estimated Bandwidth:")
                    .foregroundColor(.secondary)
                Text(qualityService.estimatedBandwidth)
                    .fontWeight(.medium)
            }
            .font(.caption)

            Button("Save Settings") {
                qualityService.save()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
