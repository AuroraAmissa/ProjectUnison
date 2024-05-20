#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p dart-sass

set -eu

cd "$(realpath "$(dirname "$0")")/../.."

# Build scss stylesheet
dart-sass --embed-sources -c resources/style.scss:build/web/resources/img/all_style.css
