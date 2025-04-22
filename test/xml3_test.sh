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

import "../xml/xml3.sh"
import "../core/util.sh"

find_tag_pairs() {
    file="$1"
    tag="$2"

    start_lines=$(grep -n "<${tag}\([ >/]\|$\)" "$file" | cut -d: -f1)
    end_lines=$(grep -n -E "<${tag}[^>]*/>|</${tag}>" "$file" | cut -d: -f1)

    set -- $start_lines
    for start in "$@"; do
        set -- $end_lines
        end="$1"
        [ -z "$start" ] || [ -z "$end" ] && break
        printf "Start: %s End: %s\n" "$start" "$end"
        shift
        end_lines="$*"
    done
}
find_tag_pairs "../test_data/web.xml" "web-app"

# data="$(cat "../test_data/basic.xml")"
# xml_lexer_partial "$data" "request-character-encoding"

# xml_tokens_debug "xml"
# echo "$map" >"./xml3_data"
