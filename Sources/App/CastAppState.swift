import Foundation
import Combine
import AppKit

@MainActor
class CastAppState: ObservableObject {
    static let shared = CastAppState()

    @Published var devices: [CastDevice] = []
    @Published var selectedDevice: CastDevice?
    @Published var isCasting = false
    @Published var castingDevice: CastDevice?
    @Published var captureMode: CaptureMode = .screen
    @Published var statusMessage = "Ready to cast"

    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadSavedDevices()
        startDeviceDiscovery()
    }

    private func loadSavedDevices() {
        // Load last used device from UserDefaults
        if let lastDeviceId = UserDefaults.standard.string(forKey: "lastUsedDeviceId") {
            // Try to find it in saved devices
        }
    }

    private func startDeviceDiscovery() {
        // Simulate device discovery with mock devices for R1
        devices = [
            CastDevice(id: "mock-1", name: "Living Room TV", model: "Chromecast", isAvailable: true),
            CastDevice(id: "mock-2", name: "Bedroom TV", model: "Google TV", isAvailable: true),
            CastDevice(id: "mock-3", name: "Office Display", model: "Chromecast Ultra", isAvailable: false),
        ]
    }

    func selectDevice(_ device: CastDevice) {
        selectedDevice = device
        UserDefaults.standard.set(device.id, forKey: "lastUsedDeviceId")
    }

    func startCasting() {
        guard let device = selectedDevice else {
            statusMessage = "No device selected"
            return
        }

        isCasting = true
        castingDevice = device
        statusMessage = "Casting to \(device.name)"
    }

    func stopCasting() {
        isCasting = false
        castingDevice = nil
        statusMessage = "Stopped casting"
    }

    func setCaptureMode(_ mode: CaptureMode) {
        captureMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "captureMode")
    }
}

enum CaptureMode: String {
    case screen = "Screen"
    case window = "Window"
    case area = "Area"
}
