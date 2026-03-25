import Foundation
import AVFoundation
import ScreenCaptureKit
import Combine

class ScreenCaptureService: NSObject {
    static let shared = ScreenCaptureService()

    private var stream: SCStream?
    private var streamOutput: CaptureStreamOutput?

    var onFrameCaptured: ((CMSampleBuffer) -> Void)?

    override init() {
        super.init()
    }

    func getAvailableDisplays() async -> [SCDisplay] {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            return content.displays
        } catch {
            print("Failed to get displays: \(error)")
            return []
        }
    }

    func getAvailableWindows() async -> [SCWindow] {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)
            return content.windows
        } catch {
            print("Failed to get windows: \(error)")
            return []
        }
    }

    func startCapture(display: SCDisplay) async throws {
        let filter = SCContentFilter(display: display, excludingWindows: [])

        let config = SCStreamConfiguration()
        config.width = Int(display.width)
        config.height = Int(display.height)
        config.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        config.queueDepth = 5

        stream = SCStream(filter: filter, configuration: config, delegate: nil)
        streamOutput = CaptureStreamOutput()
        streamOutput?.onFrameCaptured = onFrameCaptured

        try stream?.addStreamOutput(streamOutput!, type: .screen, sampleHandlerQueue: .global(qos: .userInitiated))
        try await stream?.startCapture()
    }

    func startCapture(window: SCWindow) async throws {
        let filter = SCContentFilter(desktopIndependentWindow: window)

        let config = SCStreamConfiguration()
        config.width = Int(window.frame.width)
        config.height = Int(window.frame.height)
        config.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        config.queueDepth = 5

        stream = SCStream(filter: filter, configuration: config, delegate: nil)
        streamOutput = CaptureStreamOutput()
        streamOutput?.onFrameCaptured = onFrameCaptured

        try stream?.addStreamOutput(streamOutput!, type: .screen, sampleHandlerQueue: .global(qos: .userInitiated))
        try await stream?.startCapture()
    }

    func stopCapture() async {
        do {
            try await stream?.stopCapture()
        } catch {
            print("Failed to stop capture: \(error)")
        }
        stream = nil
        streamOutput = nil
    }
}

class CaptureStreamOutput: NSObject, SCStreamOutput {
    var onFrameCaptured: ((CMSampleBuffer) -> Void)?

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        if type == .screen {
            onFrameCaptured?(sampleBuffer)
        }
    }
}
