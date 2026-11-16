import Foundation
import CoreImage
import ImageIO

enum ConvertError: LocalizedError {
    case cannotDecode
    case cannotWrite

    var errorDescription: String? {
        switch self {
        case .cannotDecode: return "Format/kamera ini belum didukung macOS kamu"
        case .cannotWrite: return "Gagal menyimpan JPG"
        }
    }
}

enum Converter {
    static let rawExtensions: Set<String> = [
        "raw", "nef", "arw", "cr2", "cr3", "crw", "nrw",
        "raf", "srf", "sr2", "orf", "rw2", "pef", "dng"
    ]

    static func isRaw(_ url: URL) -> Bool {
        rawExtensions.contains(url.pathExtension.lowercased())
    }

    private static let context = CIContext()

    /// Mengubah satu file RAW menjadi JPG. Mengembalikan lokasi & ukuran file hasil.
    static func convert(input: URL, outputDir: URL, quality: Double, maxDimension: Int?) throws -> (URL, Int64) {
        try autoreleasepool {
            try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

            // Decoder RAW bawaan macOS (sama seperti Foto & Preview)
            var image: CIImage
            if let raw = CIFilter(imageURL: input, options: nil)?.outputImage {
                image = raw
            } else if let plain = CIImage(contentsOf: input, options: [.applyOrientationProperty: true]) {
                image = plain
            } else {
                throw ConvertError.cannotDecode
            }

            // Perkecil ukuran bila diminta
            let longest = max(image.extent.width, image.extent.height)
            if let m = maxDimension, longest > CGFloat(m) {
                let scale = CGFloat(m) / longest
                image = image.applyingFilter("CILanczosScaleTransform", parameters: [
                    kCIInputScaleKey: scale,
                    kCIInputAspectRatioKey: 1.0
                ])
            }

            // Nama file unik, tidak menimpa file lain
            let base = input.deletingPathExtension().lastPathComponent
            var out = outputDir.appendingPathComponent(base + ".jpg")
            var n = 1
            while FileManager.default.fileExists(atPath: out.path) {
                out = outputDir.appendingPathComponent("\(base)-\(n).jpg")
                n += 1
            }

            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                throw ConvertError.cannotWrite
            }
            let qualityKey = CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String)
            do {
                try context.writeJPEGRepresentation(of: image, to: out, colorSpace: colorSpace, options: [qualityKey: quality])
            } catch {
                throw ConvertError.cannotWrite
            }

            let size = Int64((try? out.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
            return (out, size)
        }
    }
}
