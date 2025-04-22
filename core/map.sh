#!/bin/sh

map=""

map_key_exists() {
  mke_key="$1"
  printf "%s\n" "$map" | grep -q "^${mke_key}="
}
map_del() {
  md_key="$1"
  map="$(printf "%s\n" "$map" | { grep -v "^${md_key}=" || true; })"
}
map_set() {
  ms_key="$1"
  value="$2"

  value="$(printf "%s" "$value" | sed 's/\n/␤/g')"
  map_key_exists "$ms_key" && map_del "$ms_key"
  map="$(printf "%s\n%s=%s" "$map" "$ms_key" "$value")"
}
map_get() {
  mg_key="$1"

  printf "%s\n" "$map" | {
    grep "^${mg_key}=" | {
      IFS='=' read -r k v && printf "%s\n" "$(printf "%s" "$v" | sed 's/␤/\n/g')"
    } || return 1
  }
}

keys() {
  printf "keys:\n"
  printf "%s" "$map" | {
    while IFS='=' read -r k v || [ -n "$k" ]; do
      [ -z "$k" ] && continue
      printf "%s\n" "$k"
    done
  }
}
values() {
  printf "values:\n"
  printf "%s" "$map" | {
    while IFS='=' read -r k v || [ -n "$v" ]; do
      [ -z "$v" ] && continue
      printf "%s\n" "$v"
    done
  }
}
