import SwiftUI

struct ContentView: View {
    @ObservedObject var castingService: CastingService
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            deviceListSection
            Divider()
            controlSection
            Divider()
            footerView
        }
        .frame(width: 400, height: 360)
        .background(Theme.background)
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "display")
                .font(.title2)
                .foregroundColor(Theme.primary)

            Text("Cast")
                .font(.headline)
                .foregroundColor(Theme.text)

            Spacer()

            if castingService.isCasting {
                Circle()
                    .fill(Theme.danger)
                    .frame(width: 8, height: 8)
                Text("Casting")
                    .font(.caption)
                    .foregroundColor(Theme.danger)
            }
        }
        .padding()
        .background(Theme.surface)
    }

    private var deviceListSection: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if castingService.discoveredDevices.isEmpty {
                    emptyDevicesView
                } else {
                    ForEach(castingService.discoveredDevices) { device in
                        DeviceRow(
                            device: device,
                            isConnected: castingService.connectedDeviceName == device.name,
                            onTap: {
                                castingService.connect(to: device)
                            }
                        )
                    }
                }
            }
            .padding()
        }
        .frame(height: 160)
    }

    private var emptyDevicesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tv.and.magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(Theme.secondary)
            Text("No devices found")
                .font(.subheadline)
                .foregroundColor(Theme.secondary)
            Text("Make sure your Chromecast or Smart TV is on the same network")
                .font(.caption)
                .foregroundColor(Theme.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var controlSection: some View {
        VStack(spacing: 12) {
            Text(castingService.statusMessage)
                .font(.caption)
                .foregroundColor(Theme.secondary)

            if castingService.isConnected {
                captureButtons
            }
        }
        .padding()
        .background(Theme.surface)
    }

    private var captureButtons: some View {
        HStack(spacing: 12) {
            Button(action: { castingService.startScreenCapture() }) {
                Label("Cast Screen", systemImage: "rectangle.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(action: { castingService.startWindowCapture() }) {
                Label("Cast Window", systemImage: "macwindow")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private var footerView: some View {
        HStack {
            if castingService.isCasting {
                Button(action: { castingService.stopCasting() }) {
                    Label("Stop Casting", systemImage: "stop.fill")
                        .foregroundColor(.white)
                }
                .buttonStyle(DangerButtonStyle())
            }

            Spacer()

            if !castingService.availableWindows.isEmpty && castingService.captureMode == .window {
                Menu {
                    ForEach(castingService.availableWindows) { window in
                        Button("\(window.ownerName): \(window.name)") {
                            castingService.castWindow(withID: window.id)
                        }
                    }
                } label: {
                    Text("Select Window")
                        .font(.caption)
                }
            }

            Button(action: { castingService.refreshWindows() }) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .foregroundColor(Theme.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Theme.surface)
    }
}

struct DeviceRow: View {
    let device: CastingService.Device
    let isConnected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "tv")
                    .font(.title2)
                    .foregroundColor(isConnected ? Theme.primary : Theme.secondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.text)

                    Text(device.model)
                        .font(.caption)
                        .foregroundColor(Theme.secondary)
                }

                Spacer()

                if isConnected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.success)
                }

                Circle()
                    .fill(device.isActive ? Theme.success : Theme.secondary)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isConnected ? Theme.primary.opacity(0.1) : Theme.surface)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
