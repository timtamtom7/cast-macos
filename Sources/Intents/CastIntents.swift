import Foundation
import AppIntents

// MARK: - Start Casting Intent

struct StartCastingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Casting"
    static var description = IntentDescription("Starts casting your screen to a device")
    
    @Parameter(title: "Device Name")
    var deviceName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start casting to \(\.$deviceName)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        NotificationCenter.default.post(name: .castStart, object: nil, userInfo: ["device": deviceName])
        return .result(dialog: "Started casting to \(deviceName)")
    }
}

// MARK: - Stop Casting Intent

struct StopCastingIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Casting"
    static var description = IntentDescription("Stops the current casting session")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Stop casting")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        NotificationCenter.default.post(name: .castStop, object: nil)
        return .result(dialog: "Stopped casting")
    }
}

// MARK: - Get Cast Status Intent

struct GetCastStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Cast Status"
    static var description = IntentDescription("Returns the current casting status")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get cast status")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Would check current cast state
        return .result(value: "Not casting")
    }
}

// MARK: - App Shortcuts Provider

struct CastShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartCastingIntent(),
            phrases: [
                "Start casting in \(.applicationName)",
                "Cast my screen with \(.applicationName)"
            ],
            shortTitle: "Start Casting",
            systemImageName: "airplayvideo"
        )
        
        AppShortcut(
            intent: StopCastingIntent(),
            phrases: [
                "Stop casting in \(.applicationName)",
                "End cast in \(.applicationName)"
            ],
            shortTitle: "Stop Casting",
            systemImageName: "stop.circle"
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let castStart = Notification.Name("CastStart")
    static let castStop = Notification.Name("CastStop")
}
