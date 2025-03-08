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
import "../core/malloc.sh"
import "../core/ll.sh"

xml_lexer() {
    list="$1"
    xml="$2"
    xml_token=""

    while [ -n "$xml" ]; do
        first="${xml%"${xml#?}"}"
        xml="${xml#?}"

        case "$first" in
        '<')
            if [ -n "$xml_token" ]; then
                malloc xml_node
                object_set "$xml_node" "value" "$xml_token"
                list_append "$list" "$xml_node"
                xml_token=""
            fi
            xml_token="$first"
            ;;

        '>')
            xml_token="$xml_token$first"
            malloc xml_node
            object_set "$xml_node" "value" "$xml_token"
            list_append "$list" "$xml_node"
            xml_token=""
            ;;

        '')
            if [ -n "$xml_token" ]; then
                malloc xml_node
                object_set "$xml_node" "value" "$xml_token"
                list_append "$list" "$xml_node"
            fi
            break
            ;;

        *)
            xml_token="$xml_token$first"
            ;;
        esac
    done
}

xml_tokens_debug() {
    list_head="$1"
    curr="$list_head"

    while [ -n "$curr" ]; do
        xml_value="$(map_get "$curr.value")"
        curr="$(map_get "$curr.pointer")"
        [ -z "$xml_value" ] && continue
        printf "[%s]\n" "$xml_value"
    done
}
