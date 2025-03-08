#!/bin/sh

malloc() {
    ref="$1"

    # Generate Unique Object Name
    counter="$(map_get __malloc_counter)"
    if [ -z "$counter" ]; then
        counter=1
    fi

    map_set __malloc_counter "$((counter + 1))"

    # Store Object Name in Reference
    eval "$ref='$counter'"
}
