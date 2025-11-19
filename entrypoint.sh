#!/bin/sh -l
set -e

echo "=== Change directory to $1 ==="
cd "$1"

echo "=== Bubblewrap: building APK ==="
bubblewrap build --non-interactive --skipPwaValidation --skipSigning

APK_UNSIGNED=$(ls *.apk | grep unsigned | head -n1)
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

echo "=== Done! ==="
