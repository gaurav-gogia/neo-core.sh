#!/bin/sh

sanitize() {
    input="$1"
    printf "%s" "$input" | tr -d '\r\n\000'
}
normalize_spaces() {
    input="$1"

    # Step 1: Convert all tabs and newlines to space
    normalized="$(printf "%s" "$input" | tr '\t\r\n' ' ')"

    # Step 2: Collapse multiple spaces into one using POSIX `awk`
    # (Note: awk is POSIX and available even on busybox)
    printf "%s" "$normalized" | awk '{
        gsub(/[ ]+/, " ");
        print;
    }'
}

sanitize() {
    input="$1"
    printf "%s" "$input" | tr -d '\r\n\000'
}
normalize_spaces() {
    input="$1"

    # Step 1: Convert all tabs and newlines to space
    normalized="$(printf "%s" "$input" | tr '\t\r\n' ' ')"

    # Step 2: Collapse multiple spaces into one using POSIX awk
    # (Note: awk is POSIX and available even on busybox)
    printf "%s" "$normalized" | awk '{
        gsub(/[ ]+/, " ");
        print;
    }'
}
rm_xml_cmnts() {
    awk '
    BEGIN { in_comment = 0 }
    {
        line = $0
        while (match(line, /<!--/)) {
            in_comment = 1
            before = substr(line, 1, RSTART - 1)
            line = substr(line, RSTART + RLENGTH)
            if (match(line, /-->/)) {
                line = substr(line, RSTART + RLENGTH)
                in_comment = 0
                line = before line
            } else {
                line = before
                break
            }
        }

        if (in_comment == 0) print line
    }'
}

sanitize_xml() {
    input="$1"

    input="$(normalize_spaces "$input")"
    input="$(sanitize "$input")"
    cleaned="$(printf "%s" "$input" | rm_xml_cmnts)"
    flat="$(sanitize "$cleaned")"
    flat="$(normalize_spaces "$flat")"

    printf "%s" "$flat"
}
sanitize_xml_1() {
    flat="$(sanitize_xml "$1")"
    printf '%s' "$flat" | sed 's/>[[:space:]]*</>\n</g'
}

sanitize_xml_2() {
    flat="$(sanitize_xml "$1")"
    printf '%s' "$flat" | sed 's|>\([^<]*\)<|>\n\1\n<|g'
}
