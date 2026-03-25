import SwiftUI

struct MirrorSettingsView: View {
    @StateObject private var mirrorService = MirrorSettingsService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mirror Settings")
                .font(.headline)

            Form {
                Picker("Display Mode", selection: $mirrorService.settings.displayMode) {
                    ForEach(MirrorSettings.DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }

                Toggle("Show Cursor", isOn: $mirrorService.settings.showCursor)
                Toggle("Show Desktop Icons", isOn: $mirrorService.settings.showDesktopIcons)
                Toggle("Include Audio", isOn: $mirrorService.settings.includeAudio)
                Toggle("Use Optimal Resolution", isOn: $mirrorService.settings.useOptimalResolution)
            }

            Divider()

            Button("Save Settings") {
                mirrorService.save()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
