#!/bin/sh
echo -ne '\033c\033]0;Juice-Game\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Juice-Game.x86_64" "$@"
