#!/bin/sh

BAT=$(ls /sys/class/power_supply/ | grep -E '^BAT[0-9]+$' | head -n 1)

if [ -z "$BAT" ]; then
    echo '{"percentage": 0, "state": "Unknown", "time_to_full": 0, "time_to_empty": 0, "energy_rate": 0, "health": 100, "charge_state": 0}'
    exit 0
fi

BAT_PATH="/sys/class/power_supply/$BAT"

CAP=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo 0)
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

ENERGY_NOW=$(cat "$BAT_PATH/energy_now" 2>/dev/null || cat "$BAT_PATH/charge_now" 2>/dev/null || echo 0)
ENERGY_FULL=$(cat "$BAT_PATH/energy_full" 2>/dev/null || cat "$BAT_PATH/charge_full" 2>/dev/null || echo 0)
ENERGY_FULL_DESIGN=$(cat "$BAT_PATH/energy_full_design" 2>/dev/null || cat "$BAT_PATH/charge_full_design" 2>/dev/null || echo 0)
POWER_NOW=$(cat "$BAT_PATH/power_now" 2>/dev/null || cat "$BAT_PATH/current_now" 2>/dev/null || echo 0)

ENERGY_RATE=$(echo "scale=2; $POWER_NOW / 1000000" | bc 2>/dev/null || echo 0)

if [ "$ENERGY_FULL_DESIGN" -gt 0 ]; then
    HEALTH=$(echo "scale=1; $ENERGY_FULL * 100 / $ENERGY_FULL_DESIGN" | bc 2>/dev/null || echo 100)
else
    HEALTH=100
fi

TIME_TO_FULL=0
TIME_TO_EMPTY=0
if [ "$POWER_NOW" -gt 0 ]; then
    if [ "$STATUS" = "Charging" ]; then
        REMAINING=$((ENERGY_FULL - ENERGY_NOW))
        TIME_TO_FULL=$(echo "scale=0; $REMAINING * 3600 / $POWER_NOW" | bc 2>/dev/null || echo 0)
    elif [ "$STATUS" = "Discharging" ]; then
        TIME_TO_EMPTY=$(echo "scale=0; $ENERGY_NOW * 3600 / $POWER_NOW" | bc 2>/dev/null || echo 0)
    fi
fi

# 1=Charging, 2=Discharging, 4=Full
CHARGE_STATE=0
case "$STATUS" in
    "Charging") CHARGE_STATE=1 ;;
    "Discharging") CHARGE_STATE=2 ;;
    "Full") CHARGE_STATE=4 ;;
    "Not charging") CHARGE_STATE=4 ;;
esac

echo "{\"percentage\": $CAP, \"state\": \"$STATUS\", \"time_to_full\": $TIME_TO_FULL, \"time_to_empty\": $TIME_TO_EMPTY, \"energy_rate\": $ENERGY_RATE, \"health\": $HEALTH, \"charge_state\": $CHARGE_STATE}"
