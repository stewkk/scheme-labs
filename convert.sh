#!/usr/bin/env bash

# конвертирует каждый *.md файл в *.org,
# если файл с таким именем еще не существует

if [ ! -e "solutions/" ]; then
    mkdir "solutions"
fi

for file in *.md; do
    if [ ! -e "solutions/${file%.*}.org" ]; then
        pandoc -so "solutions/${file%.*}.org" "$file"
    fi
done
