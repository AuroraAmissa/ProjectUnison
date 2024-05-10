#!/usr/bin/env sh
pandoc -f markdown -t html --no-highlight \
    --lua-filter=scripts/pandoc/include-files.lua \
    --lua-filter=scripts/pandoc/inline-spans.lua \
    --lua-filter=scripts/pandoc/language-tags.lua \
    --lua-filter=scripts/pandoc/mdlinks-html.lua \
    "$@"
