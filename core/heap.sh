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

    set_pair "$mem.value" ""
    set_pair "$mem.left" ""
    set_pair "$mem.right" ""
}

heap_set() {
    node="$1"
    value="$2"
    set_pair "$node.value" "$value"
}

heap_get() {
    node="$1"
    get_val "$node.value"
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
            left="$(get_val "$curr.left")"
            if [ -z "$left" ]; then
                set_pair "$curr.left" "$new_node"
                return
            fi
            curr="$left"
        else
            right="$(get_val "$curr.right")"
            if [ -z "$right" ]; then
                set_pair "$curr.right" "$new_node"
                return
            fi
            curr="$right"
        fi
    done
}

heap_inorder() {
    node="$1"
    if [ -n "$node" ]; then
        heap_inorder "$(get_val "$node.left")"
        printf "%s " "$(heap_get "$node")"
        heap_inorder "$(get_val "$node.right")"
    fi
}

heap_new root
heap_insert "root" 42
heap_insert "root" 15
heap_insert "root" 50
heap_insert "root" 10
heap_insert "root" 60

printf "Root: %s\n" "$(heap_get "$root")"
left="$(get_val "$root.left")"
printf "Left: %s\n" "$(heap_get "$left")"

right="$(get_val "$root.right")"
printf "Right: %s\n" "$(heap_get "$right")"

left_left="$(get_val "$left.left")"
printf "Left Left: %s\n" "$(heap_get "$left_left")"

left_right="$(get_val "$left.right")"
printf "Left Right: %s\n" "$(heap_get "$left_right")"

right_right="$(get_val "$right.right")"
printf "Right Right: %s\n" "$(heap_get "$right_right")"

echo "$map" > data