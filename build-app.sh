#!/bin/zsh
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
app_dir="$project_dir/CodexRemainingUsage.app"
contents_dir="$app_dir/Contents"
macos_dir="$contents_dir/MacOS"
module_cache="$(mktemp -d /private/tmp/codex-usage-menu-module-cache.XXXXXX)"

mkdir -p "$macos_dir"
swiftc "$project_dir/main.swift" \
  -module-cache-path "$module_cache" \
  -framework Cocoa \
  -o "$macos_dir/CodexRemainingUsage"

cat > "$contents_dir/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>剩余用量显示</string>
    <key>CFBundleExecutable</key>
    <string>CodexRemainingUsage</string>
    <key>CFBundleIdentifier</key>
    <string>local.codex.remaining-usage</string>
    <key>CFBundleName</key>
    <string>Codex Remaining Usage</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

echo "Built: $app_dir"
