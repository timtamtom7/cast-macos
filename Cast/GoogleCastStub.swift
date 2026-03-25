import Foundation

// MARK: - Google Cast SDK Stub for macOS
// The actual Google Cast SDK for macOS must be downloaded from:
// https://developers.google.com/cast/docs/downloads
// Download the macOS SDK zip and place GoogleCast.framework in the project

// MARK: - Constants
let kGCKMediaDefaultReceiverApplicationID = "CC1AD845"

// MARK: - GCKDiscoveryCriteria
class GCKDiscoveryCriteria {
    init(forApplicationID appID: String) {}
}

// MARK: - GCKCastOptions
class GCKCastOptions {
    init(discoveryCriteria: GCKDiscoveryCriteria) {}
}

// MARK: - GCKCastContext
class GCKCastContext {
    static var sharedInstance: GCKCastContext = GCKCastContext()

    var deviceScanner: GCKDeviceScanner { GCKDeviceScanner() }
    var sessionManager: GCKSessionManager { GCKSessionManager() }
}

// MARK: - GCKDeviceScanner
class GCKDeviceScanner: NSObject {
    var devices: [GCKDevice] { [] }
    var onDeviceCountChanged: (() -> Void)?

    func startDiscovery() {}
    func stopDiscovery() {}
}

// MARK: - GCKDevice
class GCKDevice: NSObject {
    var deviceID: String { "" }
    var friendlyName: String { "" }
    var modelName: String { "" }
    var isDeviceOnLocalNetwork: Bool { false }
    var ipAddress: String? { nil }
}

// MARK: - GCKDeviceManager
class GCKDeviceManager: NSObject {
    func connect(with sessionTraits: GCKSessionTraits, sessionOptions: GCKSessionOptions?) {}
    func disconnect() {}
}

// MARK: - GCKSessionTraits
class GCKSessionTraits {
    init(applicationID: String) {}
}

// MARK: - GCKSessionOptions
class GCKSessionOptions: NSObject {}

// MARK: - GCKSessionManager
class GCKSessionManager: NSObject {
    var currentSession: GCKCastSession? { nil }
}

// MARK: - GCKCastSession
class GCKCastSession: NSObject {
    func endSession() {}
    func processBinaryMessage(_ data: Data, withIdentifier identifier: String) -> Bool { false }
}

// MARK: - GCKMediaInformation
class GCKMediaInformation {
    var streamDuration: TimeInterval { 0 }
    var mediaURL: URL? { nil }
}

// MARK: - GCKDeviceScannerListener
protocol GCKDeviceScannerListener {}

extension GCKDeviceScannerListener {
    func deviceDidCome(_ device: GCKDevice) {}
    func deviceDidGo(_ device: GCKDevice) {}
    func didStartDeviceDiscovery(for applicationID: String, deviceScanner: GCKDeviceScanner) {}
    func didUpdateDeviceList() {}
}

// MARK: - GCKDeviceManagerDelegate
protocol GCKDeviceManagerDelegate {}
