import SwiftUI

struct StreamInfoSheet: View {
    @StateObject private var streamService = StreamService.shared
    @State private var showViewerCount = false

    var body: some View {
        VStack(spacing: 16) {
            // Status
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                Text(statusText)
                    .font(.headline)
                Spacer()
            }

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(icon: "eye", title: "Current Viewers", value: "\(streamService.stats.currentViewers)")
                statCard(icon: "person.2", title: "Peak Viewers", value: "\(streamService.stats.peakViewers)")
                statCard(icon: "eye.fill", title: "Total Views", value: "\(streamService.stats.totalViews)")
                statCard(icon: "chart.bar", title: "Health", value: healthText)
            }

            // Technical stats
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Bitrate:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(streamService.stats.bitrate) kbps")
                        .font(.system(size: 13, design: .monospaced))
                }

                HStack {
                    Text("FPS:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f", streamService.stats.fps))
                        .font(.system(size: 13, design: .monospaced))
                }

                HStack {
                    Text("Dropped Frames:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(streamService.stats.droppedFrames)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(streamService.stats.droppedFrames > 10 ? .red : .primary)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            // Share URL
            HStack {
                Text("Stream URL:")
                    .foregroundColor(.secondary)
                Text("https://youtube.com/live/...")
                    .font(.system(size: 13))
                    .lineLimit(1)
                Button(action: { copyStreamURL() }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private var statusColor: Color {
        switch streamService.state {
        case .idle: return .gray
        case .connecting: return .yellow
        case .live: return .green
        case .reconnecting: return .orange
        case .ended: return .red
        }
    }

    private var statusText: String {
        switch streamService.state {
        case .idle: return "Not Streaming"
        case .connecting: return "Connecting..."
        case .live: return "LIVE"
        case .reconnecting: return "Reconnecting..."
        case .ended: return "Stream Ended"
        }
    }

    private var healthText: String {
        switch streamService.stats.healthScore {
        case 3: return "Excellent"
        case 2: return "Good"
        case 1: return "Fair"
        default: return "Poor"
        }
    }

    private func copyStreamURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("https://youtube.com/live/...", forType: .string)
    }
}
