#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p pandoc -p minify -p nix -p git

set -eu

cd "$(realpath "$(dirname "$0")")/.."
mkdir -p build/content
rm -rf build/content/* build/content/.*

# Build content
soupault --build-dir build/content
minify -vr build/content/ -o build/content/ --html-keep-comments
