#!/usr/bin/env sh
pandoc -f markdown -t html --no-highlight \
    --lua-filter=scripts/support/pandoc-include-files.lua \
    --lua-filter=scripts/support/pandoc-language.lua \
    --lua-filter=scripts/support/pandoc-mdlinks-html.lua \
    "$@"
