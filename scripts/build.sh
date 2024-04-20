#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p pandoc -p minify -p nix -p highlight

set -eu

cd "$(realpath "$(dirname "$0")")/.."
mkdir -p build/content
rm -rf build/content/* build/content/.*

# Build content
soupault --build-dir build/content
minify -vr build/content/ -o build/content/ --html-keep-comments

IMG_HASH="$(nix hash path build/content/static/img_xxxxxxxx/ --base32 | tail -c +2 | cut -c-10)"
mv -v build/content/static/img_xxxxxxxx build/content/static/"img_$IMG_HASH"
find build/content -type f -name *.html -exec sed -i "s/img_xxxxxxxx/img_$IMG_HASH/g" {} \;

JS_HASH="$(nix hash path build/content/static/js_xxxxxxxx/ --base32 | tail -c +2 | cut -c-10)"
mv -v build/content/static/js_xxxxxxxx build/content/static/"js_$JS_HASH"
find build/content -type f -name *.html -exec sed -i "s/js_xxxxxxxx/js_$JS_HASH/g" {} \;
