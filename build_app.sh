#!/bin/bash
# Membuat "Oloris Pictures.app" (macOS 12 Monterey ke atas)
set -e
cd "$(dirname "$0")"

APP="Oloris Pictures.app"
rm -rf build "$APP"
mkdir -p build

echo "🍑 Kompilasi (mencoba universal Intel + Apple Silicon)..."
if swift build -c release --arch arm64 --arch x86_64; then
    BIN="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)"
else
    echo "Universal gagal, memakai arsitektur Mac ini saja..."
    swift build -c release
    BIN="$(swift build -c release --show-bin-path)"
fi

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN/OlorisPictures" "$APP/Contents/MacOS/OlorisPictures"

echo "🎀 Membuat ikon..."
swift Scripts/make_icon.swift build/AppIcon.iconset
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Oloris Pictures</string>
    <key>CFBundleDisplayName</key><string>Oloris Pictures</string>
    <key>CFBundleIdentifier</key><string>com.oloris.pictures</string>
    <key>CFBundleExecutable</key><string>OlorisPictures</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>12.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.photography</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP"

echo ""
echo "✅ Selesai! Aplikasi ada di: $(pwd)/$APP"
echo "Seret ke folder Applications untuk memasangnya."
