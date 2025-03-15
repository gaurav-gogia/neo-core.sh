#!/bin/sh

__imports=""

import() {
    file="$1"
    case "$__imports" in
    *"|$file|"*) return ;;
    esac
    __imports="$__imports|$file|"

    if [ -f "$file" ]; then
        printf "Importing %s\n" "$file"
        . "$file"
    else
        printf "Import Error: %s not found\n" "$file" >&2
        exit 1
    fi
}

import "../core/map.sh"
import "../core/obj.sh"
import "../core/ll.sh"
import "../json/json_lexer.sh"
import "../json/json_parser.sh"

json_input='{ "name": 1 }'

json_object=""
json_lexer "json_tokens" "$json_input"
json_parse "json_tokens"

echo "Commander: $(object_get "$json_object" "name")"
# echo "Class: $(object_get "$json_object" "class")"
# echo "Level: $(object_get "$json_object" "level")"
