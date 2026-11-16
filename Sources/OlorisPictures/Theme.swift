import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

enum Theme {
    static let cream = Color(hex: 0xFFF4EA)
    static let blush = Color(hex: 0xFFE1EC)
    static let strawberry = Color(hex: 0xFF6F96)
    static let peach = Color(hex: 0xFFB48A)
    static let mint = Color(hex: 0x9FE8C8)
    static let mintDark = Color(hex: 0x2FAF80)
    static let lavender = Color(hex: 0xD9CCFF)
    static let ink = Color(hex: 0x5A3A4B)
    static let inkSoft = Color(hex: 0x9A7B8A)

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

struct CuteButtonStyle: ButtonStyle {
    var colors: [Color] = [Theme.strawberry, Theme.peach]
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.rounded(16, .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 12)
            .background(
                Capsule().fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: colors[0].opacity(0.4), radius: 10, y: 5)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .opacity(enabled ? 1 : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct Chip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.rounded(12, .bold))
                .foregroundColor(selected ? .white : Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity)
                .background(Capsule().fill(selected ? Theme.strawberry : Color.white.opacity(0.9)))
                .overlay(Capsule().stroke(selected ? Color.clear : Theme.peach.opacity(0.5), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func card() -> some View {
        self
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.white.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: Theme.strawberry.opacity(0.12), radius: 14, y: 6)
    }
}
