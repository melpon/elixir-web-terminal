#!/bin/bash

git clone --depth 1 https://github.com/libapps/libapps-mirror.git libapps
cd libapps
LIBDOT_SEARCH_PATH=`pwd` ./libdot/bin/concat.sh -i ./hterm/concat/hterm_all.concat -o ../priv/static/hterm_all.js
cd ..
rm -rf libapps
