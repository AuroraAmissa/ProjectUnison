#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p pandoc -p minify -p nix -p git -p zip
#! nix-shell -p python311 -p python311Packages.beautifulsoup4

set -eu

cd "$(realpath "$(dirname "$0")")/.."
mkdir -p build/web
rm -rf build/web/* build/web/.* ||:

# Build content
soupault --build-dir build/web
minify -vr build/web/ -o build/web/ --html-keep-comments

# Extract text
python3.11 scripts/support/extract_text.py

# Build archive
cd build
VERSION="$(git describe --always --dirty=-DIRTY)"
CONTENT_DIR="Project Unison $VERSION"
ZIP_FILE="ProjectUnison-$VERSION.zip"
rm -rf "$CONTENT_DIR" "$ZIP_FILE" dist ||:
mkdir -p dist
cp -r web "$CONTENT_DIR"
zip -r -q "$ZIP_FILE" "$CONTENT_DIR"
rm -rf "$CONTENT_DIR"
cp -v "$ZIP_FILE" dist/
