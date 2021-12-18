#!/usr/bin/env bash

show_help() {
    cat << EOF
Usage: ./exec_periodically command interval
Runs command with interval period, if command still running - kills it
Stdout redirected to ./process_stdout
Stderr redirected to ./process_stderr
EOF
}

[ "$#" -ne 2 ] && show_help && exit 0

STDOUT_FILE="./process_stdout"
STDERR_FILE="./process_stderr"

program="$1"
interval="$2"

$program > "$STDOUT_FILE" 2> "$STDERR_FILE" &
sleep $(( "$interval" * 60 ))

while true; do
    $program >> "$STDOUT_FILE" 2>> "$STDERR_FILE" &
    sleep $(( "$interval" * 60 ))
    kill -9 "$!"
done
