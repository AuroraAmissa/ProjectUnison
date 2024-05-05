#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p pandoc -p minify -p nix -p git -p zip -p linkchecker
#! nix-shell -p python311 -p python311Packages.beautifulsoup4

set -eu

cd "$(realpath "$(dirname "$0")")/.."
mkdir -p build/web
rm -rf build/web/* build/web/.* ||:

# Build content
python3.11 scripts/support/gather_headings.py
soupault --build-dir build/web

# Extract text
python3.11 scripts/support/extract_text.py

# Generate webfonts
mkdir -p build/web/resources/webfonts
scripts/support/mkwebfont -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset-from=build/text_body.txt \
    -o build/web/resources/webfonts/fonts.css fonts/MPLUS2-VariableFont_wght.ttf
scripts/support/mkwebfont -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset-from=build/text_title.txt \
    -a build/web/resources/webfonts/fonts.css fonts/MPLUSRounded1c-Bold.ttf
scripts/support/mkwebfont -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset-from=build/text_code.txt \
    -a build/web/resources/webfonts/fonts.css fonts/NotoSansMono-VariableFont_wdth,wght.ttf
scripts/support/mkwebfont -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset-from=build/text_symbols.txt \
    -a build/web/resources/webfonts/fonts.css fonts/HachiMaruPop-Regular.ttf

# Minify
minify -vr build/web/ -o build/web/ --html-keep-comments

# Check links (validation step)
linkchecker build/web/

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
