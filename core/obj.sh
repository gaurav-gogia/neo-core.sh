#!/bin/sh
readonly OBJ_EXISTS=101

object_exists() {
    oe_obj="$1"

    printf "%s\n" "$map" | {
        while IFS='=' read -r key _; do
            case "$key" in
            "$oe_obj"*) return $OBJ_EXISTS ;;
            esac
        done
    }

    if [ $? -eq $OBJ_EXISTS ]; then
        return 0
    fi
    return 1
}

object_set_pointer() {
    obj="$1"
    next="$2"
    map_set "$obj.pointer" "$next"
}
object_get_pointer() {
    obj="$1"
    map_get "$obj.pointer"
}
object_del_pointer() {
    obj="$1"
    map_del "$obj.pointer"
}

object_set() {
    obj="$1"
    key="$2"
    value="$3"

    if object_exists "$value"; then
        map_set "$obj.$key.pointer" "$value"
    else
        map_set "$obj.$key" "$value"
    fi
}
object_set_indexed() {
    obj_id=0
    malloc obj_id
    obj="${obj_id}.${1}"
    key="$2"
    value="$3"

    object_set "$obj" "$key" "$value"
}
object_print() {
    obj="$1"
    indent="${2:-0}" # Indentation level for formatting

    # Ensure the object exists before printing
    if ! object_exists "$obj"; then
        printf "Error: Object %s does not exist.\n" "$obj" >&2
        return 1
    fi

    # Indentation for nested objects
    indent_spaces="$(printf '%*s' "$indent" '')"

    printf "%s{\n" "$indent_spaces"

    first_entry=true # Track first entry to handle trailing commas

    printf "%s\n" "$map" | grep "^${obj}." | while IFS='=' read -r k v; do
        key_name="${k#"$obj."}" # Remove object prefix

        # Detect if this key is a pointer to another object
        nested_obj="$(map_get "$obj.$key_name")"

        [ "$first_entry" = false ] && printf ",\n"
        first_entry=false

        if [ -n "$nested_obj" ] && object_exists "$nested_obj"; then
            # Print nested object recursively
            printf "%s  \"%s\": " "$indent_spaces" "$key_name"
            object_print "$nested_obj" "$((indent + 2))"
        else
            printf "%s  \"%s\": \"%s\"" "$indent_spaces" "$key_name" "$v"
        fi
    done | sed '$s/,$//'

    [ "$indent" -eq 0 ] && printf "\n%s}\n" "$indent_spaces"
    [ "$indent" -gt 0 ] && printf "\n%s}" "$indent_spaces"
}
object_get() {
    obj="$1"
    key="$2"

    nested_obj="$(map_get "$obj.$key.pointer")"
    if [ -n "$nested_obj" ]; then
        object_print "$nested_obj"
    else
        map_get "$obj.$key"
    fi
}
object_del() {
    obj="$1"

    keys="$(printf "%s\n" "$map" | grep "^$obj\." | {
        while IFS='=' read -r k _; do
            printf "%s\n" "$k"
        done
    })"

    for k in $keys; do
        map_del "$k"
    done
}
object_keys() {
    ok_obj="$1"

    printf "%s\n" "$map" | {
        while IFS='=' read -r key _; do
            case "$key" in
            "$ok_obj"*) printf "%s\n" "${key#"$ok_obj."}" ;;
            esac
        done
    }
}
