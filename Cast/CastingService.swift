import Foundation
import AppKit
import ScreenCaptureKit
import AVFoundation

final class CastingService: NSObject, ObservableObject {
    @Published var isCasting: Bool = false
    @Published var isConnected: Bool = false
    @Published var connectedDeviceName: String = ""
    @Published var discoveredDevices: [Device] = []
    @Published var availableWindows: [CapturableWindow] = []
    @Published var captureMode: CaptureMode = .screen
    @Published var statusMessage: String = "Ready to cast"

    private let settingsStore: SettingsStore
    private var castContext: GCKCastContext?
    private var currentCastSession: GCKCastSession?
    private var stream: SCStream?
    private var streamOutput: CastStreamOutput?
    private var selectedWindowID: CGWindowID?

    enum CaptureMode: String, CaseIterable {
        case screen = "Screen"
        case window = "Window"
        case area = "Area"
    }

    struct Device: Identifiable, Hashable {
        let id: String
        let name: String
        let model: String
        let isActive: Bool
    }

    struct CapturableWindow: Identifiable, Hashable {
        let id: CGWindowID
        let name: String
        let ownerName: String
    }

    override init() {
        self.settingsStore = SettingsStore()
        super.init()
        setupCast()
        refreshWindows()
    }

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
        super.init()
        setupCast()
        refreshWindows()
    }

    private func setupCast() {
        castContext = GCKCastContext.sharedInstance
        loadLastUsedDevice()
    }

    private func loadLastUsedDevice() {
        if let lastDeviceID = settingsStore.lastUsedDeviceID {
            statusMessage = "Last used: \(lastDeviceID)"
        }
    }

    func refreshWindows() {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: false)

                let windows = content.windows.compactMap { window -> CapturableWindow? in
                    guard window.frame.width > 100 && window.frame.height > 100,
                          let ownerName = window.owningApplication?.applicationName,
                          !ownerName.isEmpty else {
                        return nil
                    }
                    return CapturableWindow(
                        id: window.windowID,
                        name: window.title ?? "Untitled",
                        ownerName: ownerName
                    )
                }

                await MainActor.run {
                    self.availableWindows = windows
                }
            } catch {
                print("Failed to get shareable content: \(error)")
            }
        }
    }

    func connect(to device: Device) {
        settingsStore.lastUsedDeviceID = device.id

        DispatchQueue.main.async {
            self.isConnected = true
            self.connectedDeviceName = device.name
            self.statusMessage = "Connected to \(device.name)"
        }
    }

    func disconnect() {
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectedDeviceName = ""
            self.statusMessage = "Disconnected"
        }
    }

    func startScreenCapture() {
        guard isConnected else {
            statusMessage = "No device connected"
            return
        }

        captureMode = .screen
        statusMessage = "Select a screen to cast"
        listScreens()
    }

    func startWindowCapture() {
        guard isConnected else {
            statusMessage = "No device connected"
            return
        }

        captureMode = .window
        refreshWindows()
        statusMessage = "Select a window to cast"
    }

    func castWindow(withID windowID: CGWindowID) {
        selectedWindowID = windowID
        startCapture()
    }

    func listScreens() {
        let screenNames = NSScreen.screens.map { screen in
            "Display \(screen.localizedName)"
        }
        print("Available screens: \(screenNames)")
    }

    private func startCapture() {
        statusMessage = "Starting capture..."

        let config = SCStreamConfiguration()
        config.width = 1920
        config.height = 1080
        config.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        config.queueDepth = 3
        config.showsCursor = true

        if captureMode == .screen {
            if let screen = NSScreen.main {
                config.width = Int(screen.frame.width)
                config.height = Int(screen.frame.height)
            }
        }

        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: false)

                let filter: SCContentFilter
                if self.captureMode == .window, let windowID = self.selectedWindowID {
                    if let window = content.windows.first(where: { $0.windowID == windowID }) {
                        filter = SCContentFilter(desktopIndependentWindow: window)
                    } else {
                        filter = SCContentFilter(display: content.displays.first!, excludingWindows: [])
                    }
                } else {
                    filter = SCContentFilter(display: content.displays.first!, excludingWindows: [])
                }

                self.streamOutput = CastStreamOutput(castingService: self)

                self.stream = SCStream(filter: filter, configuration: config, delegate: self)

                try self.stream?.addStreamOutput(self.streamOutput!, type: .screen, sampleHandlerQueue: .global(qos: .userInitiated))

                try await self.stream?.startCapture()

                await MainActor.run {
                    self.isCasting = true
                    self.statusMessage = "Casting to \(self.connectedDeviceName)"
                }
            } catch {
                await MainActor.run {
                    self.statusMessage = "Failed to start capture: \(error.localizedDescription)"
                }
            }
        }
    }

    func stopCasting() {
        stream?.stopCapture { [weak self] error in
            if let error = error {
                print("Error stopping capture: \(error.localizedDescription)")
            }
        }
        stream = nil

        DispatchQueue.main.async {
            self.isCasting = false
            self.statusMessage = "Stopped casting"
        }
    }

    var castSession: GCKCastSession? {
        return currentCastSession
    }
}

extension CastingService: SCStreamDelegate {
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        DispatchQueue.main.async {
            self.isCasting = false
            self.statusMessage = "Capture stopped: \(error.localizedDescription)"
        }
    }
}

final class CastStreamOutput: NSObject, SCStreamOutput {
    weak var castingService: CastingService?

    init(castingService: CastingService) {
        self.castingService = castingService
        super.init()
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen,
              let castingService = castingService,
              castingService.isCasting else {
            return
        }

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

        if let tiffData = nsImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.7]) {
            // In real implementation, send via GCKCastSession
            print("Frame captured: \(jpegData.count) bytes")
        }
    }
}
