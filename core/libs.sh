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

import_dir() {
    dir="$1"
    for file in "$dir"/*.sh; do
        [ -f "$file" ] && import "$file"
    done
}
