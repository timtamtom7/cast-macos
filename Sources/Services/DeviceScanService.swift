import Foundation
import Network

final class DeviceScanService: ObservableObject {
    static let shared = DeviceScanService()

    @Published var devices: [DiscoveredDevice] = []
    @Published var isScanning = false

    private var browser: NWBrowser?
    private var listeners: [NWListener] = []

    struct DiscoveredDevice: Identifiable, Hashable {
        let id: UUID
        let name: String
        let type: DeviceType
        let address: String
        var lastSeen: Date

        enum DeviceType: String {
            case chromecast = "Chromecast"
            case airplay = "AirPlay"
            case roku = "Roku"
            case firetv = "Fire TV"
            case dlna = "DLNA"
            case unknown = "Device"

            var icon: String {
                switch self {
                case .chromecast: return "tv.and.mediabox"
                case .airplay: return "airplayvideo"
                case .roku: return "tv"
                case .firetv: return "tv.and.mediabox"
                case .dlna: return "network"
                case .unknown: return "questionmark.circle"
                }
            }
        }
    }

    func startScanning() {
        guard !isScanning else { return }
        isScanning = true
        devices.removeAll()

        scanCastDevices()
        scanAirPlayDevices()
        scanDLNADevices()
    }

    func stopScanning() {
        browser?.cancel()
        browser = nil
        isScanning = false
    }

    private func scanCastDevices() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        browser = NWBrowser(for: .bonjour(type: "_googlecast._tcp", domain: nil), using: parameters)

        browser?.browseResultsChangedHandler = { [weak self] results, _ in
            for result in results {
                if case .service(let name, _, _, _) = result.endpoint {
                    self?.addDevice(name: name, type: .chromecast, address: result.endpoint.debugDescription)
                }
            }
        }

        browser?.stateUpdateHandler = { [weak self] state in
            if case .failed = state {
                self?.isScanning = false
            }
        }

        browser?.start(queue: .main)
    }

    private func scanAirPlayDevices() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        let browser2 = NWBrowser(for: .bonjour(type: "_airplay._tcp", domain: nil), using: parameters)

        browser2.browseResultsChangedHandler = { [weak self] results, _ in
            for result in results {
                if case .service(let name, _, _, _) = result.endpoint {
                    self?.addDevice(name: name, type: .airplay, address: result.endpoint.debugDescription)
                }
            }
        }

        browser2.start(queue: .main)
    }

    private func scanDLNADevices() {
        // SSDP discovery for DLNA devices
        discoverSSDP()
    }

    private func discoverSSDP() {
        let host: NWEndpoint.Host = "239.255.255.250"
        let port: NWEndpoint.Port = 1900

        guard let connection = NWConnection(host: host, port: port, using: .udp) else { return }

        let ssdpSearch = """
        M-SEARCH * HTTP/1.1\r
        HOST: 239.255.255.250:1900\r
        MAN: "ssdp:discover"\r
        MX: 3\r
        ST: urn:dial-multiscreen-org:service:dial:1\r
        \r

        """

        connection.send(content: ssdpSearch.data(using: .utf8), completion: .contentProcessed { error in
            if error != nil { return }

            connection.receiveMessage { data, _, _, error in
                if let data = data, let response = String(data: data, encoding: .utf8) {
                    self.parseSSDPResponse(response)
                }
            }
        })
    }

    private func parseSSDPResponse(_ response: String) {
        let lines = response.components(separatedBy: "\r\n")
        var name = "DLNA Device"
        var location: String?

        for line in lines {
            if line.lowercased().hasPrefix("server:") {
                name = String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
            }
            if line.lowercased().hasPrefix("location:") {
                location = String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            }
        }

        DispatchQueue.main.async {
            self.addDevice(name: name, type: .dlna, address: location ?? "Unknown")
        }
    }

    private func addDevice(name: String, type: DiscoveredDevice.DeviceType, address: String) {
        let device = DiscoveredDevice(
            id: UUID(),
            name: name,
            type: type,
            address: address,
            lastSeen: Date()
        )

        DispatchQueue.main.async {
            if !self.devices.contains(where: { $0.name == device.name && $0.type == device.type }) {
                self.devices.append(device)
            }
        }
    }
}
