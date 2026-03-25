import SwiftUI

struct DeviceScanView: View {
    @StateObject private var scanService = DeviceScanService.shared
    @State private var selectedDevice: DeviceScanService.DiscoveredDevice?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Available Devices")
                    .font(.headline)
                Spacer()
                Button(action: {
                    if scanService.isScanning {
                        scanService.stopScanning()
                    } else {
                        scanService.startScanning()
                    }
                }) {
                    Label(
                        scanService.isScanning ? "Stop Scanning" : "Scan",
                        systemImage: scanService.isScanning ? "stop.fill" : "magnifyingglass"
                    )
                }
                .buttonStyle(.bordered)
            }

            if scanService.isScanning {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Scanning for devices...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if scanService.devices.isEmpty && !scanService.isScanning {
                VStack(spacing: 12) {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No devices found")
                        .foregroundColor(.secondary)
                    Text("Make sure your devices are on the same network")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(scanService.devices) { device in
                            deviceRow(device)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if scanService.devices.isEmpty {
                scanService.startScanning()
            }
        }
        .onDisappear {
            scanService.stopScanning()
        }
    }

    @ViewBuilder
    private func deviceRow(_ device: DeviceScanService.DiscoveredDevice) -> some View {
        HStack {
            Image(systemName: device.type.icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.system(size: 13, weight: .medium))
                Text(device.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Cast") {
                selectedDevice = device
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedDevice?.id == device.id ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture {
            selectedDevice = device
        }
    }
}
