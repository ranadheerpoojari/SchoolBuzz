#!/bin/bash
# Generate Android upload keystore for Play Store signing
# Run: bash scripts/generate-keystore.sh

set -e

KEYSTORE_DIR="android/app"
KEYSTORE_FILE="$KEYSTORE_DIR/upload-keystore.jks"
KEY_ALIAS="upload"

echo "🔐 Generating Android upload keystore..."
echo ""

if [ -f "$KEYSTORE_FILE" ]; then
    echo "⚠️  Keystore already exists at $KEYSTORE_FILE"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS"

echo ""
echo "✅ Keystore generated: $KEYSTORE_FILE"
echo ""
echo "📋 Next steps:"
echo "   1. Copy android/key.properties.template to android/key.properties"
echo "   2. Fill in your store password and key password"
echo "   3. NEVER commit key.properties or the .jks file to git"
echo ""
echo "🔒 Add to .gitignore:"
echo "   android/key.properties"
echo "   android/app/upload-keystore.jks"
