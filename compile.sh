#!/bin/sh
# Compiles the modules in a specific order
SRC_MAIN="src/main"
luac -s -o $SRC_MAIN/excite \
    $SRC_MAIN/utils.lua \
    $SRC_MAIN/json.lua \
    $SRC_MAIN/parser.lua \
    $SRC_MAIN/format.lua \
    $SRC_MAIN/parser.lua \
    $SRC_MAIN/api.lua \
    $SRC_MAIN/init.lua \
    $SRC_MAIN/excite.lua


