#!/bin/sh -l

set -e  # Salir si hay error

echo "========================= Changing directory to $1 ========================="
cd "$1"

echo "========================= Building APK with Bubblewrap ========================="
( sleep 5 && while true; do sleep 1; echo y; done ) | bubblewrap build --skipPwaValidation --skipSigning

echo "========================= APK built. Starting alignment and signing ========================="

APK_UNSIGNED=$(ls *.apk | grep unsigned | head -n1)
APK_ALIGNED="app-aligned.apk"
APK_SIGNED="app-signed.apk"

# Alinear APK
zipalign -v -p 4 "$APK_UNSIGNED" "$APK_ALIGNED"

# Firmar APK (usando variables pasadas como args o secrets)
apksigner sign \
  --ks /github/workspace/my-release-key.jks \
  --ks-key-alias "${SIGNING_KEY_ALIAS}" \
  --ks-pass pass:"${SIGNING_STORE_PASSWORD}" \
  --key-pass pass:"${SIGNING_KEY_PASSWORD}" \
  --out "$APK_SIGNED" \
  "$APK_ALIGNED"

# Verificar
apksigner verify --verbose "$APK_SIGNED"

# Copiar APK final firmado a /github/workspace
cp "$APK_SIGNED" /github/workspace/

echo "========================= APK signed and ready ========================="