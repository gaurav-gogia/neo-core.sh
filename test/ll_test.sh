#!/bin/sh

__imports=""

import() {
    file="$1"
    case "$__imports" in
        *"|$file|"*) return ;;
    esac
    __imports="$__imports|$file|"

    if [ -f "$file" ]; then
        printf "Importing %s\n" "$file"
        . "$file"
    else
        printf "Import Error: %s not found\n" "$file" >&2
        exit 1
    fi
}

import "../core/map.sh"
import "../core/obj.sh"
import "../core/ll.sh"

object_set "root" "name" "Desmond"
object_set "root" "age" "27"

object_set "node1" "name" "Alex"
object_set "node1" "age" "26"

object_set "node2" "name" "Aquila"
object_set "node2" "age" "77"

object_set "node3" "name" "Cora"
object_set "node3" "age" "35"


printf "\n%s\n" "init list"
list_append "root" "node1"
list_iterate "root"

printf "\n%s\n" "insert node1 BEFORE node2"
list_insert_before "root" "node1" "node2"
list_iterate "root"

printf "\n%s\n" "rm node2"
list_remove "root" "node2"
list_iterate "root"

printf "\n%s\n" "append node2 back"
list_append "root" "node2"
list_iterate "root"

printf "\n%s\n" "insert node3 AFTER root"
list_insert_after "root" "root" "node3"
list_iterate "root"

echo "$map" > data
printf ""