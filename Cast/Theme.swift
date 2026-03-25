import SwiftUI

enum Theme {
    static let background = Color(nsColor: .windowBackgroundColor)
    static let surface = Color(nsColor: .controlBackgroundColor)
    static let primary = Color.blue
    static let secondary = Color.secondary
    static let text = Color.primary
    static let success = Color.green
    static let danger = Color.red
    static let warning = Color.orange

    static let cornerRadius: CGFloat = 8
    static let spacing: CGFloat = 12
    static let padding: CGFloat = 16
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.primary)
            .cornerRadius(Theme.cornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(Theme.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.primary.opacity(0.1))
            .cornerRadius(Theme.cornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.danger)
            .cornerRadius(Theme.cornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
