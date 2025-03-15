#!/bin/sh

json_parse() {
    list="$1"
    json_object=""
    json_key=""
    json_mode="KEY"

    curr="$list"

    while [ -n "$curr" ]; do
        value="$(object_get "$curr" "value")"

        case "$value" in
        '{')
            [ -n "$json_key" ] && object_set "$parent" "$json_key" "$json_object"
            parent="$json_object"
            json_key=""
            ;;
        '}')
            parent="$(object_get "$parent" "parent")"
            ;;
        ':')
            json_mode="VALUE"
            ;;
        ',')
            json_mode="KEY"
            ;;
        *)
            if [ "$json_mode" = "KEY" ]; then
                json_key="$value"
            else
                object_set "$parent" "$json_key" "$value"
                json_mode="KEY"
            fi
            ;;
        esac
        curr="$(object_get_pointer "$curr")"
    done
}
