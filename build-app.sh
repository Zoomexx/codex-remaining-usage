#!/bin/zsh
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
app_dir="${CODEX_USAGE_BUILD_APP_DIR:-$project_dir/CodexUsageMenu.app}"
contents_dir="$app_dir/Contents"
macos_dir="$contents_dir/MacOS"
module_cache="$(mktemp -d /private/tmp/codex-usage-menu-module-cache.XXXXXX)"

mkdir -p "$macos_dir"
swiftc \
  "$project_dir/Sources/UsageSnapshot.swift" \
  "$project_dir/Sources/OfficialUsageClient.swift" \
  "$project_dir/Sources/UsageSyncService.swift" \
  "$project_dir/Sources/main.swift" \
  -module-cache-path "$module_cache" \
  -framework Cocoa \
  -o "$macos_dir/CodexUsageMenu"

cat > "$contents_dir/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Codex Usage Menu</string>
    <key>CFBundleExecutable</key>
    <string>CodexUsageMenu</string>
    <key>CFBundleIdentifier</key>
    <string>local.codex.usage-menu</string>
    <key>CFBundleName</key>
    <string>Codex Usage Menu</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.3.7</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$app_dir" >/dev/null
fi

echo "Built: $app_dir"
