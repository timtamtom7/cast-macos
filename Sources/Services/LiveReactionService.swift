import Foundation

struct LiveReaction: Identifiable {
    let id = UUID()
    let emoji: String
    let count: Int
    let timestamp: Date
}

final class LiveReactionService: ObservableObject {
    static let shared = LiveReactionService()

    @Published var recentReactions: [LiveReaction] = []
    @Published var reactionCounts: [String: Int] = [:]

    private let popularEmojis = ["👏", "❤️", "🔥", "🎉", "😂", "😮", "👏👏", "💯", "🙌", "😍"]

    func addReaction(_ emoji: String) {
        let reaction = LiveReaction(emoji: emoji, count: 1, timestamp: Date())

        recentReactions.insert(reaction, at: 0)
        if recentReactions.count > 20 {
            recentReactions.removeLast()
        }

        reactionCounts[emoji, default: 0] += 1
    }

    func addRandomReaction() {
        let emoji = popularEmojis.randomElement() ?? "👏"
        addReaction(emoji)
    }

    func topReactions(limit: Int = 5) -> [(String, Int)] {
        reactionCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }

    func clearReactions() {
        recentReactions.removeAll()
        reactionCounts.removeAll()
    }
}
