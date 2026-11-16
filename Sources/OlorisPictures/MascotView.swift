import SwiftUI

enum Mood {
    case idle, busy, happy
}

private struct Smile: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.midX, y: rect.maxY * 2))
        return p
    }
}

/// Maskot "Lori", kamera kecil yang pemalu. Digambar di kotak 100x100 lalu diskalakan.
struct MascotView: View {
    var size: CGFloat = 80
    var mood: Mood = .idle

    @State private var bob = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Theme.ink.opacity(0.12))
                .frame(width: 70, height: 10)
                .offset(y: 46)

            // telinga
            Circle().fill(Theme.peach).frame(width: 22, height: 22).offset(x: -32, y: -34)
            Circle().fill(Theme.strawberry.opacity(0.7)).frame(width: 11, height: 11).offset(x: -32, y: -34)
            Circle().fill(Theme.peach).frame(width: 22, height: 22).offset(x: 32, y: -34)
            Circle().fill(Theme.strawberry.opacity(0.7)).frame(width: 11, height: 11).offset(x: 32, y: -34)

            // tombol shutter
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Theme.strawberry)
                .frame(width: 20, height: 10)
                .offset(y: -38)

            // badan
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0xFFC9D8), Theme.peach],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 88, height: 66)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.8), lineWidth: 3)
                )

            // lensa
            Circle().fill(Theme.cream).frame(width: 42, height: 42)
                .overlay(Circle().stroke(Theme.ink, lineWidth: 4))
                .offset(y: -5)
            Circle().fill(Theme.ink).frame(width: 25, height: 25).offset(y: -5)
            Circle().fill(Color.white).frame(width: 9, height: 9).offset(x: -4, y: -10)
            Circle().fill(Color.white).frame(width: 4, height: 4).offset(x: 5, y: -1)

            // pipi merona
            Ellipse().fill(Theme.strawberry.opacity(0.55)).frame(width: 14, height: 9).offset(x: -32, y: 12)
            Ellipse().fill(Theme.strawberry.opacity(0.55)).frame(width: 14, height: 9).offset(x: 32, y: 12)

            // mulut
            if mood == .busy {
                Circle().fill(Theme.ink).frame(width: 8, height: 8).offset(y: 21)
            } else {
                Smile()
                    .stroke(Theme.ink, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 16, height: 4)
                    .offset(y: 19)
            }

            if mood == .happy {
                Text("✨").font(.system(size: 18)).offset(x: 42, y: -40)
                Text("💕").font(.system(size: 14)).offset(x: -44, y: -44)
            }
        }
        .frame(width: 100, height: 100)
        .rotationEffect(.degrees(bob ? 3 : -3))
        .offset(y: bob ? -3 : 3)
        .scaleEffect(size / 100)
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: mood == .busy ? 0.5 : 1.4).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
    }
}
