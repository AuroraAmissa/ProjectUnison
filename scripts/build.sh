#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p pandoc -p minify -p nix -p git -p zip -p linkchecker -p wget -p dart-sass
#! nix-shell -p python311 -p python311Packages.beautifulsoup4

set -eu

cd "$(realpath "$(dirname "$0")")/.."
mkdir -p build/web
rm -rf build/web/* build/web/.* ||:

# Build content
python3.11 PandocRulebookBase/support/gather_headings.py
soupault --build-dir build/web

# Extract text
python3.11 PandocRulebookBase/support/extract_text.py

# Minify
minify -vr build/web/ -o build/web/ --html-keep-comments

# Copy scss resources
mkdir -p build/web/resources/img/ build/web/resources/img/PandocRulebookBase/

cp -v resources/* build/web/resources/img/
cp -v PandocRulebookBase/*.scss build/web/resources/img/PandocRulebookBase/

# Generate webfonts
mkdir -p build/web/resources/webfonts/

PandocRulebookBase/support/mkwebfont.sh -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset-from=build/text_body.txt --subset-from=build/text_code.txt \
    -a build/web/resources/img/webfonts.scss fonts/MPLUS2-VariableFont_wght.ttf
PandocRulebookBase/support/mkwebfont.sh -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset-from=build/text_title.txt \
    -a build/web/resources/img/webfonts.scss fonts/MPLUSRounded1c-Bold.ttf
PandocRulebookBase/support/mkwebfont.sh -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset-from=build/text_code.txt \
    -a build/web/resources/img/webfonts.scss fonts/NotoSansMono-VariableFont_wdth,wght.ttf
PandocRulebookBase/support/mkwebfont.sh -v --store build/web/resources/webfonts --store-uri "../webfonts/" \
    --splitter=none --subset="〈〉《》☆§●○" \
    -a build/web/resources/img/webfonts.scss fonts/HachiMaruPop-Regular.ttf

# Build scss stylesheet
dart-sass -c build/web/resources/img//style.scss:build/web/resources/img/all_style.css --style=compressed

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
