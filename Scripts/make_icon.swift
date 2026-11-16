import AppKit

// Pemakaian: swift make_icon.swift <folder-output.iconset>

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha)
}

func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let s = CGFloat(px)

    func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect {
        NSRect(x: x * s, y: y * s, width: w * s, height: h * s)
    }

    // latar squircle gradasi pink ke peach
    let bg = NSBezierPath(roundedRect: rect(0.06, 0.06, 0.88, 0.88), xRadius: s * 0.2, yRadius: s * 0.2)
    NSGradient(colors: [color(0xFF8FB1), color(0xFFB48A)])!.draw(in: bg, angle: -60)

    // telinga
    color(0xFFD9A8).setFill()
    NSBezierPath(ovalIn: rect(0.21, 0.66, 0.16, 0.16)).fill()
    NSBezierPath(ovalIn: rect(0.63, 0.66, 0.16, 0.16)).fill()
    color(0xFF6F96, 0.7).setFill()
    NSBezierPath(ovalIn: rect(0.25, 0.70, 0.08, 0.08)).fill()
    NSBezierPath(ovalIn: rect(0.67, 0.70, 0.08, 0.08)).fill()

    // badan kamera
    let body = NSBezierPath(roundedRect: rect(0.16, 0.24, 0.68, 0.48), xRadius: s * 0.14, yRadius: s * 0.14)
    NSGradient(colors: [color(0xFFFFFF), color(0xFFE6EE)])!.draw(in: body, angle: -90)

    // tombol shutter
    color(0xFF6F96).setFill()
    NSBezierPath(roundedRect: rect(0.42, 0.71, 0.16, 0.06), xRadius: s * 0.02, yRadius: s * 0.02).fill()

    // lensa
    color(0x5A3A4B).setFill()
    NSBezierPath(ovalIn: rect(0.33, 0.35, 0.34, 0.34)).fill()
    color(0xFFF4EA).setFill()
    NSBezierPath(ovalIn: rect(0.355, 0.375, 0.29, 0.29)).fill()
    color(0x5A3A4B).setFill()
    NSBezierPath(ovalIn: rect(0.395, 0.415, 0.21, 0.21)).fill()
    NSColor.white.setFill()
    NSBezierPath(ovalIn: rect(0.43, 0.54, 0.07, 0.07)).fill()
    NSBezierPath(ovalIn: rect(0.54, 0.45, 0.03, 0.03)).fill()

    // pipi merona
    color(0xFF6F96, 0.55).setFill()
    NSBezierPath(ovalIn: rect(0.22, 0.31, 0.11, 0.07)).fill()
    NSBezierPath(ovalIn: rect(0.67, 0.31, 0.11, 0.07)).fill()

    // senyum
    let smile = NSBezierPath()
    smile.move(to: NSPoint(x: 0.45 * s, y: 0.29 * s))
    smile.curve(to: NSPoint(x: 0.55 * s, y: 0.29 * s),
                controlPoint1: NSPoint(x: 0.47 * s, y: 0.255 * s),
                controlPoint2: NSPoint(x: 0.53 * s, y: 0.255 * s))
    smile.lineWidth = max(1, s * 0.016)
    smile.lineCapStyle = .round
    color(0x5A3A4B).setStroke()
    smile.stroke()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

guard CommandLine.arguments.count > 1 else {
    print("Pemakaian: swift make_icon.swift <folder.iconset>")
    exit(1)
}
let dir = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

let variants: [(String, Int)] = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024)
]
for (name, px) in variants {
    try! render(px).write(to: URL(fileURLWithPath: dir).appendingPathComponent(name))
}
print("Ikon dibuat di \(dir)")
