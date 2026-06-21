#!/bin/sh -l
set -e

# Forzar rutas fijas conocidas del Dockerfile
export BUBBLEWRAP_ALLOW_CUSTOM_SDKS=true
export ANDROID_HOME=/opt/bubblewrap/android_sdk
export JDK_PATH="/opt/bubblewrap/jdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH"

# Variables nativas de entorno que lee Bubblewrap CLI internamente
export BUBBLEWRAP_JDK_PATH="$JDK_PATH"
export BUBBLEWRAP_ANDROID_SDK_PATH="$ANDROID_HOME"

# Escribir la configuración directamente en el HOME real de GitHub Actions (/github/home)
# y también en la ruta tradicional de Node
CONFIG_CONTENT="{\"jdkPath\":\"$JDK_PATH\",\"androidSdkPath\":\"$ANDROID_HOME\"}"

mkdir -p /github/home/.bubblewrap
echo "$CONFIG_CONTENT" > /github/home/.bubblewrap/config.json

NODE_HOME=$(node -e 'console.log(require("os").homedir())')
mkdir -p "$NODE_HOME/.bubblewrap"
echo "$CONFIG_CONTENT" > "$NODE_HOME/.bubblewrap/config.json"

echo "=== Change directory to $1 ==="
cd "$1"

echo "=== Pre-validating PWA config ==="
# Se eliminó el "|| true" para que si falla aquí, el CI se detenga con un error claro
bubblewrap updateConfig --non-interactive --jdkPath="$JDK_PATH" --androidSdkPath="$ANDROID_HOME"

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
