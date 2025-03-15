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

xml_parse_attributes() {
    xml_node="$1"
    xml_attrs="$2"

    while [ -n "$xml_attrs" ]; do
        xml_attrs="${xml_attrs# }" # Strip leading spaces

        # Extract key name
        xml_key="${xml_attrs%%=*}"
        xml_rest="${xml_attrs#*=}"

        case "$xml_rest" in
        \"*)
            xml_value="${xml_rest#\"}"
            xml_value="${xml_value%%\"*}"
            xml_attrs="${xml_rest#\"$xml_value\"}"
            ;;
        *)
            # Handle unquoted values (e.g., age=30)
            xml_value="${xml_rest%% *}"
            xml_value="${xml_value%%>*}"
            xml_attrs="${xml_rest#"$xml_value"}"
            ;;
        esac

        object_set "$xml_node" "$xml_key" "$xml_value"

        xml_attrs="${xml_attrs# }"
    done
}

xml_lexer() {
    list="$1"
    xml_data="$2"
    xml_token=""
    xml_mode="TEXT"

    while :; do
        if [ -z "$xml_data" ] && [ "$xml_mode" != "DONE" ]; then
            xml_mode="DONE"
            break
        fi

        xml_first="${xml_data%"${xml_data#?}"}"
        xml_data="${xml_data#?}"

        case "$xml_first" in
        '<')
            if [ -n "$xml_token" ]; then
                object_set "$xml_node" "value" "$xml_token"
                xml_token=""
            fi
            malloc xml_node
            xml_token="$xml_first"
            ;;

        '>')
            xml_token="$xml_token$xml_first"

            # get tag name
            xml_tagname="${xml_token#<}"
            xml_tagname="${xml_tagname%% *}"
            xml_tagname="${xml_tagname%%>*}"

            object_set "$xml_node" "tag" "$xml_tagname"

            xml_attrs="${xml_token#<}"
            xml_attrs="${xml_attrs#${xml_tagname}}"
            xml_attrs="${xml_attrs%>}"
            xml_attrs="${xml_attrs# }"

            xml_parse_attributes "$xml_node" "$xml_attrs"

            list_append "$list" "$xml_node"
            xml_token=""
            ;;

        '')
            break
            ;;

        *)
            xml_token="$xml_token$xml_first"
            ;;
        esac
    done
}

xml_tokens_debug() {
    list_head="$1"
    curr="$list_head"
    indent_level="${2:-0}"

    while [ -n "$curr" ]; do
        printf "%*s[Object: %s]\n" "$indent_level" "" "$curr"

        keys="$(object_keys "$curr")"
        while IFS= read -r key; do
            [ "$key" = "pointer" ] && continue
            value="$(object_get "$curr" "$key")"
            printf "%*s- %s: %s\n" "$((indent_level + 1))" "" "$key" "$value"
        done <<EOF
$keys
EOF
        child="$(object_get_pointer "$curr")"
        if [ -n "$child" ]; then
            xml_tokens_debug "$child" "$((indent_level + 2))"
        fi

        curr="$(object_get_pointer "$curr")"
    done
}
