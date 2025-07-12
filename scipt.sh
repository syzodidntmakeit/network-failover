#!/bin/bash

# ===== Interfaces =====
PRIMARY_IF="enp5s0"                  # Ethernet
SECONDARY_IF="wlan0"                 # WiFi (Failover)

# ===== WiFi Credentials =====
SSID="${wifi_ssid}"                  # WiFi Name (set as environment variable)
PASSWORD="${wifi_password}"          # WiFi Password (set as environment variable)

# ===== Ping Configuration =====
PING_TARGET="1.1.1.1"                # Cloudflare's DNS default
PING_COUNT=1
PING_TIMEOUT=1

# ===== Notification (Telegram) =====
BOT_TOKEN="${token}"                 # Telegram Bot token (set as environment variable)
CHAT_ID="${chat_id}"                 # Telegram Chat ID (set as environment variable)

# ===== Files =====
STATE_FILE="${HOME}/.network_state"
LOG_FILE="${HOME}/network_failover.log"
LOCK_FILE="/tmp/network_failover.lock"

# ===== Functions =====

send_telegram() {
    local message="$1"
    if [[ -z "${BOT_TOKEN}" || -z "${CHAT_ID}" ]]; then
        log "Telegram notification skipped (missing credentials)"
        return
    fi

    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" \
        -d disable_notification="true" >/dev/null
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "${LOG_FILE}"
}

notify() {
    local msg="$1"
    log "${msg}"
    
    # Only show desktop notifications if running in a graphical session
    if [[ -n "${DISPLAY}" ]]; then
        notify-send "Network Failover" "${msg}"
    fi
    
    send_telegram "🔌 ${msg}"
}

connect_wifi() {
    # Check if already connected
    if nmcli -t -f DEVICE,STATE dev | grep -q "^${SECONDARY_IF}:connected"; then
        return 0
    fi

    # Verify credentials are set
    if [[ -z "${SSID}" || -z "${PASSWORD}" ]]; then
        notify "WiFi credentials not configured"
        return 1
    fi

    # Turn on WiFi radio
    if ! nmcli radio wifi on >/dev/null 2>&1; then
        notify "Failed to enable WiFi radio"
        return 1
    fi
    sleep 1

    # Try to connect using saved profile
    if ! nmcli con up id "${SSID}" >/dev/null 2>&1; then
        notify "Failed to connect to WiFi SSID: ${SSID}"
        return 1
    fi

    # Verify connection was successful
    if ! nmcli -t -f DEVICE,STATE dev | grep -q "^${SECONDARY_IF}:connected"; then
        notify "Connection to ${SSID} unsuccessful"
        return 1
    fi

    return 0
}

# ===== Main Logic =====

# Create directory for lock file if it doesn't exist
mkdir -p "$(dirname "${LOCK_FILE}")"

# Lock to prevent multiple instances
exec 9>"${LOCK_FILE}"
flock -n 9 || { log "Another instance is running"; exit 1; }

# Initialize state file if missing
[[ -f "${STATE_FILE}" ]] || echo "eth" > "${STATE_FILE}"
PREV_STATE=$(cat "${STATE_FILE}")

# Test Ethernet connection
if ping -I "${PRIMARY_IF}" -c "${PING_COUNT}" -W "${PING_TIMEOUT}" "${PING_TARGET}" >/dev/null 2>&1; then
    if [[ "${PREV_STATE}" != "eth" ]]; then
        # Disconnect WiFi and turn off radio when Ethernet is back
        nmcli device disconnect "${SECONDARY_IF}" >/dev/null 2>&1
        nmcli radio wifi off >/dev/null 2>&1
        notify "Ethernet connection restored. WiFi disabled."
        echo "eth" > "${STATE_FILE}"
    fi
else
    # Ethernet down, try to connect WiFi
    if connect_wifi; then
        if [[ "${PREV_STATE}" != "wifi" ]]; then
            notify "Ethernet down! Switched to ${SSID} WiFi."
            echo "wifi" > "${STATE_FILE}"
        fi
    else
        log "Ethernet down, but failed to connect to WiFi."
    fi
fi

# Release lock
flock -u 9
