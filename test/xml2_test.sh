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

import "../xml/xml2.sh"
import "../core/util.sh"

data="$(cat "../test_data/tom.xml")"
data="$(sanitize_xml "$data")"
xml_lexer "xml" "$data"

xml_tokens_debug "xml"
echo "$map" >data
