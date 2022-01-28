#!/usr/bin/env bash

# очень долго выполняющаяся программа
echo "executed"
>&2 echo "error"
sleep 120
