#!/bin/sh

json_parse() {
    tokens="$1"
    current="$tokens"
    json_obj=""
    json_key=""
    mode="EXPECT_KEY"

    root="$json_obj"

    while [ -n "$current" ]; do
        token="$(object_get "$current" "value")"

        case "$token" in
        '{')
            [ -n "$json_key" ] && object_set "$json_obj" "$json_key" "$child"
            object_set_pointer "$child" "$json_obj" # set parent
            json_obj="$child"
            mode="EXPECT_KEY"
            ;;

        '}')
            # Return to parent object
            parent="$(object_get_pointer "$json_obj")"
            [ -n "$parent" ] && json_obj="$parent"
            ;;

        ':')
            mode="EXPECT_VALUE"
            ;;

        ',')
            mode="EXPECT_KEY"
            ;;

        *)
            case "$mode" in
            "EXPECT_KEY")
                json_key="${token%\"}"
                json_key="${json_key#\"}"
                ;;

            "EXPECT_VALUE")
                value="${token%\"}"
                value="${value#\"}"

                object_set "$json_obj" "$json_key" "$value"
                mode="EXPECT_KEY"
                ;;
            esac
            ;;
        esac

        current="$(object_get_pointer "$current")"
    done

    # Return root object
    printf "%s" "$root"
}
