#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p pandoc -p minify -p nix -p git -p wget -p dart-sass
#! nix-shell -p python311 -p python311Packages.beautifulsoup4 -p python311Packages.tomli-w

set -eu

mkdir -p build/web/
rm -rf build/web/* build/web/.* build/soupault ||:
mkdir -p build/soupault/

# Build soupault directory
ln -s "$(pwd)/PandocRulebookBase" build/soupault/
mkdir -p build/soupault/site/web/
ln -s "$(pwd)/content" build/soupault/site/web/
python3.11 PandocRulebookBase/scripts/py/soupault_gen.py

# Build content
python3.11 PandocRulebookBase/scripts/py/gather_headings.py
soupault --config build/soupault/soupault.toml --site-dir build/soupault/site --build-dir build/web
python3.11 PandocRulebookBase/scripts/py/extract_text.py

# Minify
minify -vr build/web/ -o build/web/ --html-keep-comments

# Copy scss resources
mkdir -p build/web/web/resources/img/ build/web/web/resources/img/PandocRulebookBase/

cp -v resources/* build/web/web/resources/img/
cp -v PandocRulebookBase/*.scss build/web/web/resources/img/PandocRulebookBase/

# Generate webfonts
mkdir -p build/web/web/resources/webfonts/

pids=()
mkwebfont() {
    PandocRulebookBase/support/mkwebfont.sh -v --store build/web/web/resources/webfonts --store-uri "../webfonts/" \
        --splitter=none "${@:3}" -o build/web/web/resources/img/"$1" "fonts/$2" &
    pids+=("$!")
}
render_fonts() {
    PandocRulebookBase/support/mkwebfont.sh --help >/dev/null 2>/dev/null # download mkwebfont here

    mkwebfont wf_body.scss MPLUS2-VariableFont_wght.ttf --subset-from=build/text_body.txt --subset-from=build/text_code.txt
    mkwebfont wf_title.scss MPLUSRounded1c-Bold.ttf --subset-from=build/text_title.txt
    mkwebfont wf_code.scss NotoSansMono-VariableFont_wdth,wght.ttf --subset-from=build/text_code.txt
    mkwebfont wf_symbol.scss HachiMaruPop-Regular.ttf --subset="〈〉《》☆§●○"
    for pid in ${pids[*]}; do
        wait "$pid"
    done
}
render_fonts

# Build scss stylesheet
dart-sass -c build/web/web/resources/img/style.scss:build/web/web/resources/img/all_style.css --style=compressed
