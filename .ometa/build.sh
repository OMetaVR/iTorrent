#!/usr/bin/env bash
# Upstream's release build, unsigned and without upstream's Firebase secrets
# (this fork skips Firebase when there's no real GoogleService-Info.plist).
source "$PIPELINE/lib/helpers.sh"

XCODE=/Applications/Xcode_26.6.app
[ -d "$XCODE" ] && sudo xcode-select -s "$XCODE"
xcodebuild -version

brew install boost
./Submodules/LibTorrent-Swift/make.sh

# The project references this file; an empty placeholder keeps Firebase off.
PLIST=iTorrent/Core/Assets/GoogleService-Info.plist
[ -f "$PLIST" ] || printf '<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0"><dict/></plist>\n' > "$PLIST"

# Upstream tags are v<version>-<build>; use the build part as CFBundleVersion, like upstream.
BUILD="${UPSTREAM_TAG##*-}"
xcrun agvtool new-version -all "$BUILD" >/dev/null

ARCHIVE="$RUNNER_TEMP/iTorrent.xcarchive"
xcodebuild -workspace iTorrent.xcworkspace -scheme iTorrent -configuration Release \
  -sdk iphoneos -destination generic/platform=iOS -archivePath "$ARCHIVE" \
  -skipMacroValidation -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  clean archive | tail -n 40

APP="$ARCHIVE/Products/Applications/iTorrent.app"
codesign --force --deep --sign - "$APP"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Info.plist")
package_app "$APP" "$OUT/iTorrent_$VERSION.ipa"
