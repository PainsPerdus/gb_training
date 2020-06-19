#!/bin/bash

wla-gb -o object.o $1
echo "[objects]" > linkfile
echo "object.o" >> linkfile
wlalink -d -r -v -s linkfile "$1.gb"
rm linkfile object.o
