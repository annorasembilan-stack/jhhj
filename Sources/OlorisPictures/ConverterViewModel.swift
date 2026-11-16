import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum ItemStatus: Equatable {
    case waiting, working, done, failed(String)
}

struct PhotoItem: Identifiable {
    let id = UUID()
    let url: URL
    var status: ItemStatus = .waiting
    var inputSize: Int64
    var outputSize: Int64 = 0
    var outputURL: URL?

    var name: String { url.lastPathComponent }

    var isPending: Bool {
        switch status {
        case .waiting, .failed: return true
        case .working, .done: return false
        }
    }
}

enum SizeOption: String, CaseIterable, Identifiable {
    case original = "Asli"
    case k4 = "4096 px"
    case k2 = "2048 px"
    case hd = "1920 px"
    case web = "1080 px"

    var id: String { rawValue }

    var maxDimension: Int? {
        switch self {
        case .original: return nil
        case .k4: return 4096
        case .k2: return 2048
        case .hd: return 1920
        case .web: return 1080
        }
    }
}

func formatBytes(_ bytes: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
}

@MainActor
final class ConverterViewModel: ObservableObject {
    @Published var items: [PhotoItem] = []
    @Published var quality: Double = 0.8
    @Published var sizeOption: SizeOption = .original
    @Published var useCustomFolder = false
    @Published var customFolder: URL?
    @Published var isRunning = false
    @Published var isTargeted = false

    // MARK: - Ringkasan

    var doneCount: Int { items.filter { $0.status == .done }.count }
    var pendingCount: Int { items.filter { $0.isPending }.count }
    var failedCount: Int {
        items.filter { if case .failed = $0.status { return true } else { return false } }.count
    }

    var progress: Double {
        guard !items.isEmpty else { return 0 }
        let finished = items.filter { item in
            switch item.status {
            case .done, .failed: return true
            default: return false
            }
        }.count
        return Double(finished) / Double(items.count)
    }

    var mood: Mood {
        if isRunning { return .busy }
        if !items.isEmpty && pendingCount == 0 { return .happy }
        return .idle
    }

    var qualityMood: String {
        switch quality {
        case ..<0.5: return "Hemat banget, file mungil 🐭"
        case ..<0.75: return "Seimbang, ukuran kecil & rapi 🍑"
        case ..<0.9: return "Bagus, cocok untuk dibagikan 🌸"
        default: return "Maksimal, detail terjaga 💎"
        }
    }

    var summary: String {
        let done = items.filter { $0.status == .done }
        let totalIn = done.reduce(Int64(0)) { $0 + $1.inputSize }
        let totalOut = done.reduce(Int64(0)) { $0 + $1.outputSize }
        guard totalIn > 0 else { return "" }
        let saved = max(0, 100 - Int(Double(totalOut) / Double(totalIn) * 100))
        return "✨ \(done.count) foto selesai: \(formatBytes(totalIn)) → \(formatBytes(totalOut)) (lebih kecil \(saved)%)"
    }

    // MARK: - Menambah file

    func add(urls: [URL]) {
        for url in urls {
            for file in expand(url) where !items.contains(where: { $0.url == file }) {
                let size = Int64((try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                items.append(PhotoItem(url: file, inputSize: size))
            }
        }
    }

    private func expand(_ url: URL) -> [URL] {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else { return [] }
        if isDir.boolValue {
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )
            let all = (enumerator?.allObjects as? [URL]) ?? []
            return all.filter { Converter.isRaw($0) }.sorted { $0.path < $1.path }
        }
        return Converter.isRaw(url) ? [url] : []
    }

    func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, _ in
                var found: URL?
                if let data = item as? Data {
                    found = URL(dataRepresentation: data, relativeTo: nil)
                } else if let u = item as? URL {
                    found = u
                }
                guard let url = found else { return }
                Task { @MainActor [weak self] in
                    self?.add(urls: [url])
                }
            }
        }
    }

    func pickFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.message = "Pilih foto RAW atau folder berisi foto RAW"
        panel.prompt = "Pilih"
        panel.allowedFileTypes = Array(Converter.rawExtensions)
        if panel.runModal() == .OK {
            add(urls: panel.urls)
        }
    }

    func pickOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Pilih folder untuk menyimpan JPG"
        panel.prompt = "Simpan di sini"
        if panel.runModal() == .OK, let url = panel.url {
            customFolder = url
            useCustomFolder = true
        }
    }

    func remove(_ id: UUID) {
        items.removeAll { $0.id == id }
    }

    func clear() {
        guard !isRunning else { return }
        items.removeAll()
    }

    func revealResults() {
        let urls = items.compactMap { $0.outputURL }
        if !urls.isEmpty {
            NSWorkspace.shared.activateFileViewerSelecting(urls)
        }
    }

    // MARK: - Proses

    func start() {
        guard !isRunning else { return }
        let ids = items.filter { $0.isPending }.map { $0.id }
        guard !ids.isEmpty else { return }

        isRunning = true
        let q = quality
        let maxDim = sizeOption.maxDimension
        let folder: URL? = useCustomFolder ? customFolder : nil

        Task {
            for id in ids {
                guard let i = items.firstIndex(where: { $0.id == id }) else { continue }
                items[i].status = .working
                let url = items[i].url
                let dir = folder ?? url.deletingLastPathComponent().appendingPathComponent("Oloris JPG", isDirectory: true)

                let result: Result<(URL, Int64), Error> = await Task.detached(priority: .userInitiated) {
                    Result { try Converter.convert(input: url, outputDir: dir, quality: q, maxDimension: maxDim) }
                }.value

                guard let j = items.firstIndex(where: { $0.id == id }) else { continue }
                switch result {
                case .success(let (out, size)):
                    items[j].status = .done
                    items[j].outputURL = out
                    items[j].outputSize = size
                case .failure(let error):
                    items[j].status = .failed(error.localizedDescription)
                }
            }
            isRunning = false
        }
    }
}
