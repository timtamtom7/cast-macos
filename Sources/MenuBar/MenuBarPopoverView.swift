import SwiftUI

struct MenuBarPopoverView: View {
    @StateObject private var appState = CastAppState.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "display")
                    .foregroundColor(.accentColor)

                Text("Cast")
                    .font(.headline)

                Spacer()

                Button(action: { openMainWindow() }) {
                    Image(systemName: "arrow.up.right.square")
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Status
            if appState.isCasting {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)

                    Text(appState.statusMessage)
                        .font(.caption)
                }
                .padding()
            }

            // Device list
            VStack(alignment: .leading, spacing: 8) {
                Text("Available Devices")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(appState.devices) { device in
                            DeviceRowView(device: device, isSelected: appState.selectedDevice?.id == device.id)
                                .onTapGesture {
                                    appState.selectDevice(device)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Divider()

            // Capture mode
            VStack(spacing: 8) {
                Text("Capture Mode")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    ForEach([CaptureMode.screen, .window], id: \.self) { mode in
                        Button(action: { appState.setCaptureMode(mode) }) {
                            VStack(spacing: 4) {
                                Image(systemName: mode == .screen ? "rectangle.on.rectangle" : "macwindow")
                                    .font(.title2)
                                Text(mode.rawValue)
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(appState.captureMode == mode ? Color.accentColor.opacity(0.2) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()

            // Cast button
            if appState.isCasting {
                Button(action: { appState.stopCasting() }) {
                    Label("Stop Casting", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.horizontal)
            } else {
                Button(action: { appState.startCasting() }) {
                    Label("Start Casting", systemImage: "display")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(appState.selectedDevice == nil)
                .padding(.horizontal)
            }

            Divider()

            // Footer
            HStack {
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)

                Spacer()

                Button("Preferences...") {
                    // Show preferences
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
            .padding()
        }
        .frame(width: 360, height: 480)
    }

    private func openMainWindow() {
        // Would open main window
    }
}

struct DeviceRowView: View {
    let device: CastDevice
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: device.iconName)
                .font(.title3)
                .foregroundColor(device.isAvailable ? .primary : .secondary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .fontWeight(.medium)
                    .foregroundColor(device.isAvailable ? .primary : .secondary)

                Text(device.model)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            } else if !device.isAvailable {
                Text("Offline")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
