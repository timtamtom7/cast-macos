import Foundation
import StoreKit

/// R16: Subscription management for Cast
@available(macOS 13.0, *)
public final class CastSubscriptionManager: ObservableObject {
    public static let shared = CastSubscriptionManager()
    @Published public private(set) var subscription: CastSubscription?
    @Published public private(set) var products: [Product] = []
    
    private init() {}
    
    public func loadProducts() async {
        do {
            products = try await Product.products(for: [
                "com.cast.macos.pro.monthly",
                "com.cast.macos.pro.yearly",
                "com.cast.macos.household.monthly",
                "com.cast.macos.household.yearly"
            ])
        } catch { print("Failed to load products") }
    }
    
    public func canAccess(_ feature: CastFeature) -> Bool {
        guard let sub = subscription else { return false }
        switch feature {
        case .advancedCasting: return sub.tier != .free
        case .widgets: return sub.tier != .free
        case .shortcuts: return sub.tier != .free
        case .multipleRooms: return sub.tier != .free
        }
    }
    
    public func updateStatus() async {
        var found: CastSubscription = CastSubscription(tier: .free)
        for await result in Transaction.currentEntitlements {
            do {
                let t = try checkVerified(result)
                if t.productID.contains("household") {
                    found = CastSubscription(tier: .household, status: t.revocationDate == nil ? "active" : "expired")
                } else if t.productID.contains("pro") {
                    found = CastSubscription(tier: .pro, status: t.revocationDate == nil ? "active" : "expired")
                }
            } catch { continue }
        }
        await MainActor.run { self.subscription = found }
    }
    
    public func restore() async throws {
        try await AppStore.sync()
        await updateStatus()
    }
    
    private func checkVerified<T>(_ r: VerificationResult<T>) throws -> T {
        switch r { case .unverified: throw NSError(domain: "Cast", code: -1); case .verified(let s): return s }
    }
}

public enum CastFeature { case advancedCasting, widgets, shortcuts, multipleRooms }
