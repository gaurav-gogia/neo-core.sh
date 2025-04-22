#!/bin/sh

json_lexer() {
    set -efu

    ref="$1"
    json_data="$2"
    json_token=""
    json_mode="TEXT"

    while [ -n "$json_data" ]; do
        json_first="${json_data%"${json_data#?}"}"
        json_data="${json_data#?}"

        case "$json_mode" in
        "STRING")
            json_token="$json_token$json_first"
            [ "$json_first" = '"' ] && {
                list_append "$ref" "$json_token"
                json_token=""
                json_mode="TEXT"
            }
            ;;

        "TEXT")
            case "$json_first" in
            '{' | '}' | '[' | ']' | ':' | ',')
                [ -n "$json_token" ] && {
                    list_append "$ref" "$json_token"
                    json_token=""
                }
                list_append "$ref" "$json_first"
                ;;

            '"')
                json_token='"'
                json_mode="STRING"
                ;;

            ' ' | $'\n' | $'\t')
                [ -n "$json_token" ] && {
                    list_append "$ref" "$json_token"
                    json_token=""
                }
                ;;

            *)
                json_token="$json_token$json_first"
                ;;
            esac
            ;;
        esac
    done

    [ -n "$json_token" ] && list_append "$ref" "$json_token"

    set +efu
}
