#!/bin/sh

get_files() {
    dir="$1"
    pattern="$2"
    files=""

    find "$dir" -type f -name "$pattern" >tmplist

    while IFS= read -r file; do
        files="${files}${file}␤"
    done <tmplist

    rm -f tmplist

    printf "%s" "$files" # ✅ Ensure `files` is printed
}

files="$(get_files "." "*")"

IFS=␤
echo "$files" | while read -r file; do
    [ -n "$file" ] && printf "Found: %s\n" "$file"
done

unset IFS
