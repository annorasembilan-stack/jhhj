# Oloris Pictures 🍑📷

Aplikasi macOS untuk mengubah dan mengompres foto RAW menjadi JPG, dengan tampilan pastel yang lucu dan maskot kamera bernama Lori.

**Format didukung:** RAW, NEF, ARW, CR2, CR3, CRW, NRW, RAF, SRF, SR2, ORF, RW2, PEF, DNG
**Sistem:** macOS 12 Monterey sampai versi terbaru (Intel dan Apple Silicon)

## Cara membuat aplikasinya

1. Pasang alat pengembang (sekali saja). Buka Terminal, lalu jalankan: `xcode-select --install`
   (Xcode penuh dari App Store juga boleh, dan dibutuhkan agar hasilnya universal Intel + Apple Silicon.)
2. Buka Terminal di folder ini, lalu jalankan:
   ```
   chmod +x build_app.sh
   ./build_app.sh
   ```
3. Hasilnya `Oloris Pictures.app`. Seret ke folder Applications.
4. Saat pertama dibuka, bila muncul peringatan keamanan: klik kanan aplikasi, pilih **Open**, lalu **Open** lagi.

## Cara memakai

- Seret foto RAW (atau folder berisi foto RAW) ke jendela, atau klik **Pilih Foto…**
- Atur kualitas JPG, ukuran sisi terpanjang, dan lokasi simpan.
- Klik **Mulai Kompres**. File RAW asli tidak pernah diubah.
- Secara bawaan hasil masuk ke folder `Oloris JPG` di samping foto asli.

## Catatan

- Decoding RAW memakai mesin RAW bawaan macOS (seperti aplikasi Foto). Kamera yang terlalu baru mungkin baru terbaca setelah macOS diperbarui, dan format sangat tua seperti CRW bisa saja tidak terbaca di beberapa versi macOS.
- Struktur kode: `Converter.swift` (konversi), `ConverterViewModel.swift` (logika), `ContentView.swift` (tampilan), `MascotView.swift` (maskot), `Theme.swift` (warna dan gaya).

## Tanpa Mac / tanpa Xcode: build otomatis di GitHub

1. Buat repository baru di GitHub (boleh private), lalu unggah seluruh isi folder ini (termasuk folder `.github`).
2. Buka tab **Actions**, pilih **Build Oloris Pictures**, tunggu sampai hijau (sekitar 3-5 menit).
3. Buka run yang selesai, unduh artifact **OlorisPictures-macOS** di bagian bawah, ekstrak.
4. Karena aplikasi belum ditandatangani Apple, jalankan sekali di Terminal: `xattr -cr "Oloris Pictures.app"`, lalu seret ke Applications.
