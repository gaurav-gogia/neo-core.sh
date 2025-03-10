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

  value="${value//$'\n'/␤}"  # Replace newlines with ␤
  map_key_exists "$key" && map_del "$ms_key"
  map="$(printf "%s\n%s=%s" "$map" "$ms_key" "$value")"
}
map_get() {
  mg_key="$1"

  printf "%s\n" "$map" | {
    grep "^${mg_key}=" | {
      IFS='=' read -r k v && printf "%s\n" "${v//␤/$'\n'}"
    } || return 1
  }
}


keys() {
  printf "keys:\n"
  printf "$map" | {
    while IFS='=' read -r k v || [ -n "$k" ]; do
      [ -z "$k" ] && continue
      printf "%s\n" "$k"
    done
  }
}
values() {
  printf "values:\n"
  printf "$map" | {
    while IFS='=' read -r k v || [ -n "$v" ] ; do
      [ -z "$v" ] && continue
      printf "%s\n" "$v"
    done
  }
}