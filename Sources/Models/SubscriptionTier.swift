import Foundation

/// R16: Subscription tiers for Cast
public enum CastSubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case pro = "pro"
    case household = "household"
    
    public var displayName: String {
        switch self { case .free: return "Free"; case .pro: return "Cast Pro"; case .household: return "Cast Household" }
    }
    public var monthlyPrice: Decimal? {
        switch self { case .free: return nil; case .pro: return 2.99; case .household: return 4.99 }
    }
    public var maxDevices: Int {
        switch self { case .free: return 1; case .pro: return 3; case .household: return 10 }
    }
    public var supportsAdvancedCasting: Bool { self != .free }
    public var supportsWidgets: Bool { self != .free }
    public var supportsShortcuts: Bool { self != .free }
    public var supportsMultipleRooms: Bool { self != .free }
    public var trialDays: Int { self == .free ? 0 : 14 }
}

public struct CastSubscription: Codable {
    public let tier: CastSubscriptionTier
    public let status: String
    public let expiresAt: Date?
    public init(tier: CastSubscriptionTier, status: String = "active", expiresAt: Date? = nil) {
        self.tier = tier; self.status = status; self.expiresAt = expiresAt
    }
}
