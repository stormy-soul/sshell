#!/bin/bash

OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
USER=$(whoami)

if command -v hostnamectl &> /dev/null; then
    HOST=$(hostnamectl | grep "Static hostname" | cut -d: -f2 | xargs)
    CHASSIS=$(hostnamectl | grep "Chassis" | cut -d: -f2 | xargs)
fi

if [ -z "$HOST" ]; then
    HOST=$(uname -n)
fi

if [ -z "$CHASSIS" ]; then
    CHASSIS="desktop"
fi

PFP=""

if [ -f "$HOME/.face" ]; then
    PFP="$HOME/.face"
elif [ -f "$HOME/.face.icon" ]; then
    PFP="$HOME/.face.icon"
elif [ -f "/var/lib/AccountsService/icons/$USER" ]; then
    PFP="/var/lib/AccountsService/icons/$USER"
fi

echo "{\"os\": \"$OS_ID\", \"user\": \"$USER\", \"host\": \"$HOST\", \"pfp\": \"$PFP\", \"chassis\": \"$CHASSIS\"}"

