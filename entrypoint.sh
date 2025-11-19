#!/bin/sh -l
set -e

echo "=== Moving to project root: $1 ==="
cd "$1"

echo "=== Building via Bubblewrap ==="
bubblewrap build --skipPwaValidation --skipSigning --non-interactive

echo "=== Locating unsigned APK ==="
APK_UNSIGNED=$(ls *.apk | grep unsigned | head -n1)

if [ -z "$APK_UNSIGNED" ]; then
  echo "ERROR: Couldn't find APK unsigned"
  exit 1
fi

APK_ALIGNED="app-aligned.apk"
APK_SIGNED="app-signed.apk"

echo "=== Zipalign ==="
zipalign -v -p 4 "$APK_UNSIGNED" "$APK_ALIGNED"

echo "=== Signing APK ==="
apksigner sign \
  --ks /github/workspace/my-release-key.jks \
  --ks-key-alias "$SIGNING_KEY_ALIAS" \
  --ks-pass pass:"$SIGNING_STORE_PASSWORD" \
  --key-pass pass:"$SIGNING_KEY_PASSWORD" \
  --out "$APK_SIGNED" \
  "$APK_ALIGNED"

apksigner verify --verbose "$APK_SIGNED"

echo "=== DONE ==="
