import SwiftUI

struct LiveReactionsView: View {
    @StateObject private var reactionService = LiveReactionService.shared

    let emojis = ["👏", "❤️", "🔥", "🎉", "😂", "😮", "💯", "🙌", "😍", "🎊"]

    var body: some View {
        VStack(spacing: 16) {
            Text("Live Reactions")
                .font(.headline)

            // Reaction picker
            HStack(spacing: 8) {
                ForEach(emojis, id: \.self) { emoji in
                    Button(action: { reactionService.addReaction(emoji) }) {
                        Text(emoji)
                            .font(.system(size: 24))
                    }
                    .buttonStyle(.plain)
                    .help("Send \(emoji)")
                }
            }

            Divider()

            // Top reactions
            if !reactionService.topReactions().isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Reactions")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(reactionService.topReactions(), id: \.0) { emoji, count in
                        HStack {
                            Text(emoji)
                                .font(.title3)
                            Text(count > 1 ? "\(emoji) × \(count)" : emoji)
                                .font(.system(size: 13))
                            Spacer()
                        }
                    }
                }
            }

            // Recent reactions
            if !reactionService.recentReactions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(reactionService.recentReactions.prefix(10)) { reaction in
                                HStack {
                                    Text(reaction.emoji)
                                    Text(reaction.timestamp, style: .relative)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 100)
                }
            }

            Button("Clear All") {
                reactionService.clearReactions()
            }
            .buttonStyle(.plain)
            .foregroundColor(.red)
        }
        .padding()
    }
}
