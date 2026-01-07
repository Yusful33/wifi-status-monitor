# WiFi Status Monitor

A lightweight macOS menu bar indicator that monitors your internet connectivity and alerts you when the connection goes down.

## Features

- Shows **green checkmark** when connected, **red dot** when disconnected
- Checks connectivity every 5 seconds
- Displays current latency in dropdown menu
- macOS notification when internet goes down
- Tracks when the connection was lost

## Screenshots

**Connected:**
```
✅
---
Status: Connected
Latency: 21ms
```

**Disconnected:**
```
🔴
---
Status: DISCONNECTED
Down since: 10:42:15
---
Switch to cellular tethering
```

## Requirements

- macOS
- [xbar](https://xbarapp.com/) (free menu bar app)

## Installation

### 1. Install xbar

```bash
brew install --cask xbar
```

### 2. Install the plugin

```bash
# Clone this repository
git clone https://github.com/Yusful33/wifi-status-monitor.git

# Copy the script to xbar plugins folder
cp wifi-status-monitor/internet-status.5s.sh ~/Library/Application\ Support/xbar/plugins/

# Make it executable
chmod +x ~/Library/Application\ Support/xbar/plugins/internet-status.5s.sh
```

### 3. Launch xbar

Open xbar from Applications. You should see the status indicator in your menu bar.

**Tip:** Enable "Start at Login" in xbar preferences to auto-start on boot.

## How It Works

The script pings three reliable endpoints every 5 seconds:
1. `8.8.8.8` (Google DNS)
2. `1.1.1.1` (Cloudflare DNS)
3. `google.com` (DNS resolution test)

If **any** ping succeeds, you're online. If **all** fail, you're offline.

## Customization

Edit the script to customize:

- **Check interval:** Rename the file (e.g., `internet-status.10s.sh` for 10 seconds)
- **Ping targets:** Modify the `TARGETS` array
- **Timeout:** Adjust the `TIMEOUT` variable

## License

MIT
