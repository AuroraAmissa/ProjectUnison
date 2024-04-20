#!/bin/sh

set -eu

cd "$(realpath "$(dirname "$0")")/.."

mkdir -p site/static/webfonts
rm site/static/webfonts/* ||:
scripts/support/mkwebfont -v --store site/static/webfonts --store-uri /static/webfonts/ \
    --preload-in "Hachi Maru Pop:☆♡《》" \
    -o site/static/img_xxxxxxxx/fonts.css fonts/*
