#!/bin/bash
# Build the menu-bar app and package it as a double-clickable .app bundle.
set -euo pipefail
cd "$(dirname "$0")"

APP="Crypto → Wall Street"
DIR="dist/${APP}.app"

swift build -c release
BIN="$(swift build -c release --show-bin-path)/CryptoWallStreet"

rm -rf "$DIR"
mkdir -p "$DIR/Contents/MacOS" "$DIR/Contents/Resources"
cp "$BIN" "$DIR/Contents/MacOS/CryptoWallStreet"

cat > "$DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Crypto → Wall Street</string>
  <key>CFBundleDisplayName</key><string>Crypto → Wall Street</string>
  <key>CFBundleIdentifier</key><string>com.hazy.cryptowallstreet</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleExecutable</key><string>CryptoWallStreet</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# Ad-hoc sign so Gatekeeper lets it launch locally.
codesign --force --deep --sign - "$DIR" 2>/dev/null || true

echo "Built: $DIR"
