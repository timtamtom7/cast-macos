import Foundation

final class SettingsStore: ObservableObject {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let lastUsedDeviceID = "lastUsedDeviceID"
        static let preferredCaptureMode = "preferredCaptureMode"
        static let rememberedDevices = "rememberedDevices"
        static let audioEnabled = "audioEnabled"
        static let qualityPreset = "qualityPreset"
    }

    var lastUsedDeviceID: String? {
        get { defaults.string(forKey: Keys.lastUsedDeviceID) }
        set { defaults.set(newValue, forKey: Keys.lastUsedDeviceID) }
    }

    var preferredCaptureMode: String {
        get { defaults.string(forKey: Keys.preferredCaptureMode) ?? "Screen" }
        set { defaults.set(newValue, forKey: Keys.preferredCaptureMode) }
    }

    var rememberedDevices: [String: String] {
        get { defaults.dictionary(forKey: Keys.rememberedDevices) as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: Keys.rememberedDevices) }
    }

    var audioEnabled: Bool {
        get { defaults.bool(forKey: Keys.audioEnabled) }
        set { defaults.set(newValue, forKey: Keys.audioEnabled) }
    }

    var qualityPreset: String {
        get { defaults.string(forKey: Keys.qualityPreset) ?? "1080p" }
        set { defaults.set(newValue, forKey: Keys.qualityPreset) }
    }

    func addRememberedDevice(id: String, name: String) {
        var devices = rememberedDevices
        devices[id] = name
        rememberedDevices = devices
    }

    func removeRememberedDevice(id: String) {
        var devices = rememberedDevices
        devices.removeValue(forKey: id)
        rememberedDevices = devices
    }

    func isDeviceRemembered(id: String) -> Bool {
        rememberedDevices[id] != nil
    }
}
