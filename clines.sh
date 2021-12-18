#!/usr/bin/env bash

show_help() {
    cat << EOF
Usage: ./clines [-h] [path...]
Count nonempty lines in C source code files at paths

-h, --help    Display this message
EOF
}

count_nonempty_lines() {
    grep -cv '^$' "$1"
}

[ "$1" = "--help" ] || [ "$1" = "-h" ] && show_help && exit 0

paths=( "$@" )
[ "${paths[*]}" ] || paths="."

programs=$(find "${paths[@]}" -name '*.c' -o -name '*.h')
[ ! "$programs" ] && echo "C source files not found in $paths" 1>&2 && exit 1

ans=0
while read -r file; do
    (( ans += $(count_nonempty_lines "$file") ))
done <<< "$programs"
echo "$ans"
