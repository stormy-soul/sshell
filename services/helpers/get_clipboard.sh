#!/bin/bash
if [ -z "$1" ]; then
    cliphist list | head -n 50
else
    cliphist list | grep -i "$1" | head -n 50
fi
