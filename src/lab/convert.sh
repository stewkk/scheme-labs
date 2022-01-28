#!/usr/bin/env bash

# конвертирует каждый *.md файл в *.org,
# если файл с таким именем еще не существует

for file in ./*.md; do
    if [ ! -e "${file%.*}.org" ]; then
        pandoc -so "${file%.*}.org" "$file"
    fi
done
