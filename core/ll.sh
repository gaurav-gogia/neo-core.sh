#!/bin/sh

object_set_pointer() {
    obj="$1"
    next="$2"
    object_set "$obj" "pointer" "$next"
}
object_get_pointer() {
    obj="$1"
    object_get "$obj" "pointer"
}
object_del_pointer() {
  obj="$1"
  delete_pair "$obj.pointer"
}

list_find_and_modify() {
    list_head="$1"
    target="$2"
    new="$3"
    mode="$4"  # "append", "before", or "after"

    curr="$list_head"
    prev=""

    while [ -n "$curr" ]; do
        if [ "$mode" = "append" ] && [ -z "$(object_get_pointer "$curr")" ]; then
            object_set_pointer "$curr" "$new"
            return 0
        fi

        if [ "$curr" = "$target" ]; then
            case "$mode" in
                "before")
                    object_set_pointer "$new" "$curr"
                    if [ -n "$prev" ]; then
                        object_set_pointer "$prev" "$new"
                    else
                        eval "$list_head='$new'"
                    fi
                    return 0
                    ;;
                "after")
                    next="$(object_get_pointer "$curr")"
                    object_set_pointer "$new" "$next"
                    object_set_pointer "$curr" "$new"
                    return 0
                    ;;
            esac
        fi

        prev="$curr"
        curr="$(object_get_pointer "$curr")"
    done

    return 1  # Target not found
}


list_insert_before() {
    list_find_and_modify "$1" "$2" "$3" "before"
}
list_insert_after() {
    list_find_and_modify "$1" "$2" "$3" "after"
}
list_append() {
    list_find_and_modify "$1" "" "$2" "append"
}

list_remove() {
    list_head="$1"
    target="$2"

    curr="$list_head"
    prev=""

    while [ -n "$curr" ]; do
        if [ "$curr" = "$target" ]; then
            next="$(object_get_pointer "$curr")"

            if [ -n "$prev" ]; then
                object_set_pointer "$prev" "$next"
            fi

            if [ "$curr" = "$list_head" ]; then
                eval "$list_head='$next'"
            fi

            object_del_pointer "$target"
            return 0
        fi

        prev="$curr"
        curr="$(object_get_pointer "$curr")"
    done

    return 1
}

list_object_dump() {
    obj="$1"
    printf "%s" "$mem" | {
        grep "^$obj\." | {
            while IFS='=' read k v; do
                printf "    %s=%s\n" "${k#$obj.}" "$v"
            done
        }
    }
}

list_iterate() {
    head="$1"
    curr="$head"

    while [ -n "$curr" ]; do
        printf "Object %s\n" "$curr"
        list_object_dump "$curr"
        curr="$(object_get_pointer "$curr")"
    done
}