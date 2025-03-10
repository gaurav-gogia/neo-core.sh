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

object_set "person" "first_name" "andrew"
object_set "person" "last_name" "flintoff"

object_set "bcci" "type" "company"
object_set "bcci" "game" "ghud savari"

object_set "ipl" "type" "subcompany"
object_set "ipl" "bun" "fun"
object_set "ipl" "wicket" 1241421251

object_set "person" "affiliation" "bcci"
object_set "bcci" "subffl" "ipl"

object_print "person"

echo "$map" >data
