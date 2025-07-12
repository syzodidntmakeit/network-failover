# Network Failover Automation Script

## 📖 Overview

A robust Bash script that automatically monitors your primary network connection (Ethernet) and fails over to a secondary WiFi connection when outages are detected. Provides real-time notifications and maintains detailed logs of all network transitions.

## ✨ Features

- **Automatic Failover**: Seamless transition to backup WiFi when Ethernet fails
- **Self-Healing**: Automatically reverts to Ethernet when restored
- **Multi-Notification System**:
  - Desktop notifications (GUI environments)
  - Telegram bot alerts
- **Intelligent Monitoring**: Regular ping checks to verify connectivity
- **State Persistence**: Remembers connection state between runs
- **Thread-Safe Operation**: File locking prevents concurrent execution
- **Comprehensive Logging**: Detailed operation log for troubleshooting

## 🛠️ Technical Details

### Dependencies
| Package | Purpose |
|---------|---------|
| `nmcli` | NetworkManager control |
| `ping` | Connection testing |
| `curl` | Telegram notifications |
| `notify-send` | Desktop alerts |

### File Structure


## 🚀 Getting Started

### Prerequisites
- Linux system with NetworkManager
- Bash 4.0+
- Configured WiFi network

### Installation
```bash
git clone https://github.com/yourusername/network-failover.git
cd network-failover
chmod +x network_failover.sh
```

### Configuration
Insert your credentials into the config.env
```bash
# WiFi Configuration
WIFI_SSID="YourNetworkName"
WIFI_PASSWORD="YourSecurePassword"

# Telegram Configuration
TELEGRAM_BOT_TOKEN="your_bot_token"
TELEGRAM_CHAT_ID="your_chat_id"

# Ping Settings
PING_TARGET="1.1.1.1"
```

### Usage
```bash
# Manual run
./network_failover.sh

# Automated via cron (every 5 minutes)
(crontab -l ; echo "*/5 * * * * /path/to/network_failover.sh >> /var/log/network_failover.log 2>&1") | crontab -
```

### Customization
Interface Adjustments
```bash
# Change these variables in the script:
PRIMARY_IF="eth0"            # Your Ethernet interface
SECONDARY_IF="wlan0"          # Your WiFi interface
PING_TIMEOUT=2                # Increase for unstable networks
```
Notification Icons
```bash
🔌 - Connection change
✅ - Restoration
❌ - Failure
⚠️ - Warning
```
### Logs & Troubleshooting
Logs are stored in: ~/network_failover.log

Sample log entries:
```text
2023-11-15 14:30:45: Ethernet connection restored. WiFi disabled.
2023-11-15 14:25:32: Ethernet down! Switched to OfficeWiFi WiFi.
```
You good, brodie? -w-
