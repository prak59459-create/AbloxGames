#!/usr/bin/env bash
# Builds the catalogue: every game's world, listing and index.json.
#
#   ABLOX=../Ablox tools/build.sh [--only N] [--quick]
#
# ABLOX is a checkout of https://github.com/prak59459-create/Ablox. The
# generator is compiled together with its portable core (AbloxCore), so the
# worlds are written — and the games checked and played — by the same code
# the app runs.
set -euo pipefail
cd "$(dirname "$0")/.."

ABLOX="${ABLOX:-../Ablox}"
CORE="$ABLOX/Ablox.swiftpm/Sources/AbloxCore"
if [ ! -d "$CORE" ]; then
  echo "Set ABLOX to a checkout of the Ablox repository (looked in $ABLOX)." >&2
  exit 2
fi

OUT="${TMPDIR:-/tmp}/ablox-catalogue-generator"
mkdir -p "$OUT"
swiftc -O -module-name CatalogueGenerator -o "$OUT/generate" \
  "$CORE"/*.swift tools/generator/*.swift
"$OUT/generate" "$@"
