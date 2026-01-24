#!/bin/sh

BAT=$(ls /sys/class/power_supply/ | grep -E '^BAT[0-9]+$' | head -n 1)

if [ -z "$BAT" ]; then
    echo '{"percentage": 0, "state": "Unknown"}'
    exit 0
fi

CAP=$(cat /sys/class/power_supply/$BAT/capacity)
STATUS=$(cat /sys/class/power_supply/$BAT/status)

echo "{\"percentage\": $CAP, \"state\": \"$STATUS\"}"
