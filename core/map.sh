#!/bin/sh

map=""

key_exists() {
  key="$1"
  printf "%s\n" "$map" | grep -q "^${key}="
}
delete_pair() {
  key="$1"
  map="$(printf "%s\n" "$map" | { grep -v "^${key}=" || true; })"
}
set_pair() {
  key="$1"
  value="$2"
  
  value="${value//$'\n'/␤}"  # Replace newlines with ␤
  key_exists "$key" && delete_pair "$key"
  map="$(printf "%s\n%s=%s" "$map" "$key" "$value")"
}
get_val() {
  key="$1"

  printf "%s\n" "$map" | {
    grep "^${key}=" | {
      IFS='=' read k v && printf "%s\n" "${v//␤/$'\n'}"
    } || return 1
  }
}


keys() {
  printf "keys:\n"
  printf "$map" | {
    while IFS='=' read k v || [ -n "$k" ]; do
      [ -z "$k" ] && continue
      printf "%s\n" "$k"
    done
  }
}
values() {
  printf "values:\n"
  printf "$map" | {
    while IFS='=' read k v || [ -n "$v" ] ; do
      [ -z "$v" ] && continue
      printf "%s\n" "$v"
    done
  }
}