# Network Failover Automation Script

## Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Customization](#-customization)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

## 📖 Overview

This Bash script provides automatic network redundancy by:
1. Continuously monitoring your primary Ethernet connection
2. Failing over to WiFi when outages are detected
3. Automatically reverting when Ethernet is restored
4. Sending real-time notifications through multiple channels

Perfect for servers, workstations, or IoT devices requiring uninterrupted connectivity.

## ✨ Features

| Feature | Benefit |
|---------|---------|
| **Automatic Failover** | Zero downtime during network outages |
| **Self-Healing** | Returns to primary connection automatically |
| **Dual Alerts** | Desktop + Telegram notifications |
| **Smart Detection** | Configurable ping checks |
| **State Tracking** | Remembers connection state between runs |
| **Single Instance** | Prevents duplicate executions |
| **Detailed Logging** | Timestamped record of all events |

## 🛠️ Requirements

### Essential Packages
```bash
sudo apt install network-manager iputils-ping curl libnotify-bin
```
### Hardware Requirements
- Ethernet interface
- WiFi adapter
- Internet connection
