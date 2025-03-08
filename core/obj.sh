#!/bin/sh

object_set() {
    obj="$1"
    key="$2"
    value="$3"
    map_set "$obj.$key" "$value"
}
object_set_indexed() {
    obj_id=0
    malloc obj_id
    obj="${obj_id}.${1}"
    key="$2"
    value="$3"
    map_set "$obj.$key" "$value"
}
object_get() {
    obj="$1"
    key="$2"
    map_get "$obj.$key"
}
object_del() {
    obj="$1"

    keys="$(printf "%s\n" "$map" | grep "^$obj\." | {
        while IFS='=' read k v; do
            printf "%s\n" "$k"
        done
    })"

    for k in $keys; do
        map_del "$k"
    done
}
object_keys() {
    obj="$1"

    printf "%s\n" "$map" | {
        while IFS='=' read -r key _; do
            case "$key" in
            "$obj"*) printf "%s\n" "${key#"$obj."}" ;;
            esac
        done
    }
}
