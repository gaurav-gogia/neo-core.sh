#!/bin/sh

mem=""
malloc() {
    ref="$1"
    mem=$((mem + 1))
    eval "$ref='$mem'"
}

heap_new() {
    ref="$1"
    malloc "$ref"

    map_set "$mem.value" ""
    map_set "$mem.left" ""
    map_set "$mem.right" ""
}

heap_set() {
    node="$1"
    value="$2"
    map_set "$node.value" "$value"
}

heap_get() {
    node="$1"
    map_get "$node.value"
}

heap_insert() {
    root="$1"
    value="$2"

    malloc new_node
    heap_set "$new_node" "$value"

    if [ -z "$root" ]; then
        eval "$root='$new_node'"
        return
    fi

    curr="$root"

    while :; do
        curr_val="$(heap_get "$curr")"

        if [ -n "$curr_val" ] && [ "$value" -lt "$curr_val" ]; then
            left="$(map_get "$curr.left")"
            if [ -z "$left" ]; then
                map_set "$curr.left" "$new_node"
                return
            fi
            curr="$left"
        else
            right="$(map_get "$curr.right")"
            if [ -z "$right" ]; then
                map_set "$curr.right" "$new_node"
                return
            fi
            curr="$right"
        fi
    done
}

heap_inorder() {
    node="$1"
    if [ -n "$node" ]; then
        heap_inorder "$(map_get "$node.left")"
        printf "%s " "$(heap_get "$node")"
        heap_inorder "$(map_get "$node.right")"
    fi
}

heap_new root
heap_insert "root" 42
heap_insert "root" 15
heap_insert "root" 50
heap_insert "root" 10
heap_insert "root" 60

printf "Root: %s\n" "$(heap_get "$root")"
left="$(map_get "$root.left")"
printf "Left: %s\n" "$(heap_get "$left")"

right="$(map_get "$root.right")"
printf "Right: %s\n" "$(heap_get "$right")"

left_left="$(map_get "$left.left")"
printf "Left Left: %s\n" "$(heap_get "$left_left")"

left_right="$(map_get "$left.right")"
printf "Left Right: %s\n" "$(heap_get "$left_right")"

right_right="$(map_get "$right.right")"
printf "Right Right: %s\n" "$(heap_get "$right_right")"

echo "$map" >data
