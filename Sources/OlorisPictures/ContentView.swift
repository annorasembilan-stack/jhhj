import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var vm: ConverterViewModel

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.cream, Theme.blush], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            Circle().fill(Theme.lavender.opacity(0.45)).frame(width: 300, height: 300)
                .blur(radius: 50).offset(x: 320, y: -220)
            Circle().fill(Theme.mint.opacity(0.35)).frame(width: 260, height: 260)
                .blur(radius: 50).offset(x: -340, y: 260)

            VStack(spacing: 16) {
                header
                HStack(alignment: .top, spacing: 16) {
                    mainPanel
                    SettingsPanel().frame(width: 290)
                }
                footer
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .padding(.top, 14)
        }
        .preferredColorScheme(.light)
        .onDrop(of: [UTType.fileURL], isTargeted: $vm.isTargeted) { providers in
            vm.handleDrop(providers)
            return true
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            MascotView(size: 70, mood: vm.mood)
            VStack(alignment: .leading, spacing: 2) {
                Text("Oloris Pictures")
                    .font(Theme.rounded(32, .heavy))
                    .foregroundColor(Theme.ink)
                Text("Ubah foto RAW jadi JPG yang kecil & manis ✨")
                    .font(Theme.rounded(14, .medium))
                    .foregroundColor(Theme.inkSoft)
            }
            Spacer()
            Text("RAW → JPG")
                .font(Theme.rounded(13, .bold))
                .foregroundColor(Theme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(Theme.lavender))
        }
        .padding(.top, 16)
    }

    // MARK: Panel utama

    private var mainPanel: some View {
        ZStack {
            if vm.items.isEmpty {
                DropZoneView()
            } else {
                FileListView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .card()
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(vm.isTargeted ? Theme.strawberry : Color.clear, lineWidth: 4)
        )
        .scaleEffect(vm.isTargeted ? 1.01 : 1)
        .animation(.spring(), value: vm.isTargeted)
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                if vm.items.isEmpty {
                    Text("Belum ada foto. Yuk tambah dulu! 📷")
                } else if vm.isRunning {
                    ProgressView(value: vm.progress).tint(Theme.strawberry)
                    Text("Memproses \(vm.doneCount) dari \(vm.items.count) foto…")
                } else if vm.doneCount > 0 {
                    Text(vm.summary)
                    if vm.failedCount > 0 {
                        Text("\(vm.failedCount) foto gagal, lihat keterangannya di daftar.")
                            .foregroundColor(Theme.strawberry)
                    }
                } else {
                    Text("Siap memproses \(vm.items.count) foto 🎀")
                }
            }
            .font(Theme.rounded(14, .semibold))
            .foregroundColor(Theme.ink)

            Spacer()

            if vm.doneCount > 0 && !vm.isRunning {
                Button("Buka Hasil 📂") { vm.revealResults() }
                    .buttonStyle(CuteButtonStyle(colors: [Theme.mintDark, Theme.mint]))
            }
            if vm.pendingCount > 0 || vm.isRunning {
                Button(vm.isRunning ? "Memproses…" : (vm.doneCount > 0 ? "Proses Sisanya 🍑" : "Mulai Kompres 🍑")) {
                    vm.start()
                }
                .buttonStyle(CuteButtonStyle(enabled: !vm.isRunning))
                .disabled(vm.isRunning)
            }
        }
        .frame(minHeight: 44)
        .card()
    }
}

// MARK: - Area seret & lepas

struct DropZoneView: View {
    @EnvironmentObject var vm: ConverterViewModel

    var body: some View {
        VStack(spacing: 14) {
            MascotView(size: 110, mood: vm.isTargeted ? .happy : .idle)
            Text(vm.isTargeted ? "Lepaskan di sini, aku siap! 🥰" : "Seret foto RAW ke sini")
                .font(Theme.rounded(22, .bold))
                .foregroundColor(Theme.ink)
            Text("Folder berisi foto juga boleh, nanti kupilihkan yang RAW saja.")
                .font(Theme.rounded(13, .medium))
                .foregroundColor(Theme.inkSoft)
                .multilineTextAlignment(.center)
            Button("Pilih Foto…") { vm.pickFiles() }
                .buttonStyle(CuteButtonStyle())
                .padding(.top, 4)
            Text("NEF · ARW · CR2 · CR3 · CRW · NRW · RAF · SRF · SR2 · ORF · RW2 · PEF · DNG · RAW")
                .font(Theme.rounded(11, .medium))
                .foregroundColor(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 2.5, dash: [9, 7]))
                .foregroundColor(Theme.peach)
        )
    }
}

// MARK: - Daftar foto

struct FileListView: View {
    @EnvironmentObject var vm: ConverterViewModel

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(vm.items.count) foto")
                    .font(Theme.rounded(16, .bold))
                    .foregroundColor(Theme.ink)
                Spacer()
                Button("Tambah") { vm.pickFiles() }
                    .buttonStyle(.plain)
                    .disabled(vm.isRunning)
                Button("Bersihkan") { vm.clear() }
                    .buttonStyle(.plain)
                    .disabled(vm.isRunning)
            }
            .font(Theme.rounded(13, .bold))
            .foregroundColor(Theme.strawberry)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(vm.items) { item in
                        PhotoRow(item: item)
                    }
                }
            }
        }
    }
}

struct PhotoRow: View {
    @EnvironmentObject var vm: ConverterViewModel
    let item: PhotoItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.lavender.opacity(0.6))
                Image(systemName: "photo.fill").foregroundColor(Theme.ink.opacity(0.7))
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(Theme.rounded(14, .semibold))
                    .foregroundColor(Theme.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(detail)
                    .font(Theme.rounded(12, .medium))
                    .foregroundColor(isFailed ? Theme.strawberry : Theme.inkSoft)
                    .lineLimit(1)
            }
            Spacer()
            statusView
            if !vm.isRunning {
                Button { vm.remove(item.id) } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.inkSoft.opacity(0.6))
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white.opacity(0.85)))
    }

    private var isFailed: Bool {
        if case .failed = item.status { return true }
        return false
    }

    private var detail: String {
        switch item.status {
        case .done:
            let saved = item.inputSize > 0 ? max(0, 100 - Int(Double(item.outputSize) / Double(item.inputSize) * 100)) : 0
            return "\(formatBytes(item.inputSize)) → \(formatBytes(item.outputSize))  (lebih kecil \(saved)%)"
        case .failed(let message):
            return message
        default:
            return formatBytes(item.inputSize)
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch item.status {
        case .waiting:
            Image(systemName: "clock.fill").foregroundColor(Theme.lavender)
        case .working:
            ProgressView().scaleEffect(0.6).frame(width: 20, height: 20)
        case .done:
            Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.mintDark)
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Theme.strawberry)
        }
    }
}

// MARK: - Pengaturan

struct SettingsPanel: View {
    @EnvironmentObject var vm: ConverterViewModel

    private let columns = [GridItem(.adaptive(minimum: 78), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Pengaturan manis 🎀")
                .font(Theme.rounded(18, .bold))
                .foregroundColor(Theme.ink)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    label("Kualitas JPG")
                    Spacer()
                    Text("\(Int(vm.quality * 100))%")
                        .font(Theme.rounded(14, .bold))
                        .foregroundColor(Theme.strawberry)
                }
                Slider(value: $vm.quality, in: 0.3...1.0, step: 0.05)
                    .tint(Theme.strawberry)
                Text(vm.qualityMood)
                    .font(Theme.rounded(12, .medium))
                    .foregroundColor(Theme.inkSoft)
            }

            VStack(alignment: .leading, spacing: 8) {
                label("Sisi terpanjang")
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(SizeOption.allCases) { option in
                        Chip(title: option.rawValue, selected: vm.sizeOption == option) {
                            vm.sizeOption = option
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                label("Simpan hasil di")
                Chip(title: "📁 Samping foto asli", selected: !vm.useCustomFolder) {
                    vm.useCustomFolder = false
                }
                Chip(title: vm.customFolder.map { "🎯 \($0.lastPathComponent)" } ?? "🎯 Pilih folder…",
                     selected: vm.useCustomFolder) {
                    vm.pickOutputFolder()
                }
            }

            Spacer(minLength: 0)

            Text("File RAW aslimu tidak diubah. Hasil JPG masuk ke folder “Oloris JPG” bila disimpan di samping foto asli.")
                .font(Theme.rounded(11, .medium))
                .foregroundColor(Theme.ink.opacity(0.8))
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.lavender.opacity(0.5)))
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .card()
        .disabled(vm.isRunning)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(Theme.rounded(14, .bold))
            .foregroundColor(Theme.ink)
    }
}
