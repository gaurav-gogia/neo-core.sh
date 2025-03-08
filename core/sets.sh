#!/bin/sh

sets=""

has_key() {
  key="$1"
  printf "%s\n" "$map" | grep -q "^${key}="
}
delete_set() {
  key="$1"
  map="$(printf "%s\n" "$map" | { grep -v "^${key}=" || true; })"
}
set_key() {
  key="$1"

  has_key "$key"
  if [ $? -eq 0 ]; then
    delete_set "$key"
  fi
  map="$(printf "%s\n%s=%s" "$map" "$key" "")"
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