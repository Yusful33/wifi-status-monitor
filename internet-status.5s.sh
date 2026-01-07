#!/bin/bash

# Internet Connectivity Monitor for xbar
# Checks connectivity every 5 seconds (per filename)
# Shows ✅ when connected, 🔴 when disconnected

STATE_FILE="/tmp/internet-monitor-state"
TIMEOUT=1  # seconds per ping

# Ping targets (if ANY succeeds, we're online)
TARGETS=("8.8.8.8" "1.1.1.1" "google.com")

# Check connectivity by pinging targets
check_connectivity() {
    for target in "${TARGETS[@]}"; do
        if ping -c 1 -W $TIMEOUT "$target" &>/dev/null; then
            return 0  # Success - we're online
        fi
    done
    return 1  # All pings failed - we're offline
}

# Get latency to first responsive target (macOS format)
get_latency() {
    for target in "${TARGETS[@]}"; do
        result=$(ping -c 1 -W $TIMEOUT "$target" 2>/dev/null | grep "round-trip")
        if [ -n "$result" ]; then
            # Extract avg from "round-trip min/avg/max/stddev = X/Y/Z/W ms"
            echo "$result" | sed -E 's/.*= [0-9.]+\/([0-9.]+)\/.*/\1/'
            return
        fi
    done
    echo "N/A"
}

# Send macOS notification
send_notification() {
    osascript -e "display notification \"$1\" with title \"Internet Monitor\""
}

# Get previous state
get_previous_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "unknown"
    fi
}

# Save current state
save_state() {
    echo "$1" > "$STATE_FILE"
}

# Main logic
previous_state=$(get_previous_state)

if check_connectivity; then
    current_state="online"
    latency=$(get_latency)

    # Menu bar icon
    echo "✅"
    echo "---"
    echo "Status: Connected | color=green"
    echo "Latency: ${latency}ms"
    echo "---"
    echo "Targets: 8.8.8.8, 1.1.1.1, google.com | size=10"
    echo "---"
    echo "Refresh | refresh=true"
else
    current_state="offline"

    # Menu bar icon
    echo "🔴"
    echo "---"
    echo "Status: DISCONNECTED | color=red"

    # Show when it went down
    if [ "$previous_state" = "online" ]; then
        echo "$current_state $(date '+%H:%M:%S')" > "$STATE_FILE"
        send_notification "Internet connection lost! Switch to cellular tethering."
    fi

    # Try to show when it went down
    if [ -f "$STATE_FILE" ]; then
        down_info=$(cat "$STATE_FILE")
        if [[ "$down_info" == offline* ]]; then
            down_time=$(echo "$down_info" | cut -d' ' -f2)
            echo "Down since: $down_time | color=red"
        fi
    fi

    echo "---"
    echo "⚠️ Switch to cellular tethering | color=orange"
    echo "---"
    echo "Refresh | refresh=true"
fi

# Save state (but preserve down time if still offline)
if [ "$current_state" = "online" ]; then
    save_state "$current_state"
elif [ "$previous_state" = "online" ]; then
    # Just went offline - save with timestamp
    echo "offline $(date '+%H:%M:%S')" > "$STATE_FILE"
fi
