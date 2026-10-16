#!/bin/sh
# Builds WireOracle, the iPad's own PacketCodec run on its own, against an
# Ablox checkout (AbloxCore is plain Swift, so it builds on Linux too):
#
#   tools/wireoracle/build.sh ../../Ablox
#   .wireoracle/.build/release/WireOracle emit ../ test/fixtures/wire-swift.json
#   WIRE_OUT=/tmp/wire-web.json npx vitest run test/wire.test.ts
#   .wireoracle/.build/release/WireOracle check /tmp/wire-web.json /tmp/wire-checked.json
#   WIRE_CHECKED=/tmp/wire-checked.json npx vitest run test/wire.test.ts
set -e
ablox="$(cd "${1:?usage: build.sh <path to the Ablox repository>}" && pwd)"
here="$(cd "$(dirname "$0")" && pwd)"
out="$here/../../.wireoracle"
rm -rf "$out/Sources"
mkdir -p "$out/Sources/WireOracle"
cat > "$out/Package.swift" <<'SWIFT'
// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "WireOracle", targets: [.executableTarget(name: "WireOracle", path: "Sources/WireOracle")])
SWIFT
for f in "$ablox"/Ablox.swiftpm/Sources/AbloxCore/*.swift; do ln -s "$f" "$out/Sources/WireOracle/"; done
ln -s "$here/main.swift" "$out/Sources/WireOracle/main.swift"
cd "$out" && swift build -c release
