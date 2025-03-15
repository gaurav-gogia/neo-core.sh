#!/bin/sh

json_lexer() {
    set -efu

    ref="$1"
    json_data="$2"
    json_token=""
    json_mode="TEXT"

    while [ -n "$json_data" ]; do
        # Extract first character safely
        json_first="${json_data%"${json_data#?}"}"
        json_data="${json_data#?}"

        case "$json_first" in
        '{' | '}' | '[' | ']' | ':' | ',')
            # Store previous token if it exists
            if [ -n "$json_token" ]; then
                list_append "$ref" "$json_token"
                json_token=""
            fi
            # Store single-character tokens directly
            list_append "$ref" "$json_first"
            ;;

        '"')
            if [ "$json_mode" = "TEXT" ]; then
                json_mode="STRING"
                json_token="$json_first"
            elif [ "$json_mode" = "STRING" ]; then
                json_mode="TEXT"
                json_token="$json_token$json_first"
                list_append "$ref" "$json_token"
                json_token=""
            fi
            ;;

        ' ')
            # Ignore spaces **only** outside strings
            if [ "$json_mode" = "STRING" ]; then
                json_token="$json_token$json_first"
            elif [ -n "$json_token" ]; then
                list_append "$ref" "$json_token"
                json_token=""
            fi
            ;;

        *)
            json_token="$json_token$json_first"
            ;;
        esac

        if [ -z "$json_data" ]; then
            break
        fi
    done

    if [ -n "$json_token" ]; then
        list_append "$ref" "$json_token"
    fi

    set +efu
}
