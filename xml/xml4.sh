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
import "../core/util.sh"

xml_parse_attributes() {
    node="$1"
    attrs="$2"

    while [ -n "$attrs" ]; do
        attrs="${attrs# }" # leading space
        [ -z "$attrs" ] && break

        key="${attrs%%=*}" # up to '='
        rest="${attrs#*=}"

        case "$rest" in
        \"*)
            val="${rest#\"}"
            val="${val%%\"*}"        # up to closing quote
            attrs="${rest#\"$val\"}" # trim key="val"
            ;;
        *)
            val="${rest%% *}" # unquoted until space
            val="${val%%>*}"  # or tag end
            attrs="${rest#"$val"}"
            ;;
        esac

        # store and loop
        key="$(printf "%s" "$key" | tr -d ' \n\t')" # trim internal ws/newline
        object_set "$node" "$key" "$val"
    done
}

xml_lexer() { # $1 = list head, $2 = raw xml
    list="$1"
    data="$(sanitize_xml_2 "$2")"
    while IFS= read -r line; do
        case "$line" in
        "<"*) # it’s a tag
            malloc node
            # grab tag name
            tag="${line#<}"
            tag="${tag%% *}"
            tag="${tag%%>*}"
            object_set "$node" tag "$tag"
            # attributes (everything after tag name to >)
            attrs="${line#<${tag}}"
            attrs="${attrs%>}"
            [ -n "$attrs" ] && xml_parse_attributes "$node" "$attrs"
            list_append "$list" "$node"
            ;;
        *) # text node (value)
            [ -n "$node" ] && object_set "$node" value "$line"
            ;;
        esac
    done <<EOF
$(printf "%s" "$data")
EOF
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
