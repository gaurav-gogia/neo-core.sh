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

data="$(cat "../test_data/tom.xml")"
data="$(sanitize_xml_1 "$data")"
while IFS= read -r line; do
    [ -z "$line" ] && continue # Skip empty lines
    xml_lexer "xml" "$line"
    echo "$line"
done <<EOF
$(printf "%s" "$data")
EOF

xml_tokens_debug "xml"
echo "$map" >"./xml3_data"
