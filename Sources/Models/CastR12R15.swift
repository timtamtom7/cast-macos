import Foundation

// MARK: - Cast R12-R15 Models

struct CastTeam: Identifiable, Codable {
    let id: UUID
    var name: String
    var members: [CastMember]
    var sharedDevices: [SharedDevice]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        members: [CastMember] = [],
        sharedDevices: [SharedDevice] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.sharedDevices = sharedDevices
        self.createdAt = createdAt
    }
}

struct CastMember: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String

    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

struct SharedDevice: Identifiable, Codable {
    let id: UUID
    var deviceId: UUID
    var shareCode: String
    var expiresAt: Date?

    init(
        id: UUID = UUID(),
        deviceId: UUID,
        shareCode: String = String(UUID().uuidString.prefix(8)).uppercased(),
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.deviceId = deviceId
        self.shareCode = shareCode
        self.expiresAt = expiresAt
    }
}

struct CastingSession: Identifiable, Codable {
    let id: UUID
    var deviceName: String
    var contentType: String
    var startTime: Date
    var endTime: Date?
    var bytesTransferred: Int64

    init(
        id: UUID = UUID(),
        deviceName: String,
        contentType: String,
        startTime: Date = Date(),
        endTime: Date? = nil,
        bytesTransferred: Int64 = 0
    ) {
        self.id = id
        self.deviceName = deviceName
        self.contentType = contentType
        self.startTime = startTime
        self.endTime = endTime
        self.bytesTransferred = bytesTransferred
    }
}
