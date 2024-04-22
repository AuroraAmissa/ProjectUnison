#!/bin/sh

set -eu

cd "$(realpath "$(dirname "$0")")/.."

mkdir -p site/resources/webfonts
rm -v site/resources/webfonts/* ||:
scripts/support/mkwebfont -v --store site/resources/webfonts --store-uri "../webfonts/" \
    --preload-in "Hachi Maru Pop:☆♡《》" \
    -o site/resources/webfonts/fonts.css fonts/*
