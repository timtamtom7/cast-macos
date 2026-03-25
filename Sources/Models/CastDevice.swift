import Foundation

struct CastDevice: Identifiable, Hashable {
    let id: String
    let name: String
    let model: String
    var isAvailable: Bool
    var isCasting: Bool = false

    var iconName: String {
        switch model.lowercased() {
        case "chromecast", "chromecast ultra":
            return "chromecast"
        case "google tv", "android tv":
            return "tv"
        default:
            return "tv"
        }
    }
}
