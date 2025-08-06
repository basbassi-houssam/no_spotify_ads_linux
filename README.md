# 🎵 Mute Spotify Ads Automatically – Shell Script for Linux
Tired of annoying Spotify ads interrupting your music? This lightweight shell script automatically **mutes Spotify during ads** and **restores the volume once the ad ends**.
> ✅ Works with the **Spotify Desktop App only** (not the web player).
> ⚡ Supports most Linux distributions.

---

## ⭐ Features

### 🎯 **Core Functionality**
- 🔇 **Smart Ad Detection** – Automatically detects Spotify advertisements using multiple detection methods
- 🔊 **Intelligent Muting** – Mutes only Spotify's audio (or system-wide as fallback) during ads
- ⚡ **Fast Response** – Sub-second detection and muting for seamless experience
- 🎵 **Volume Preservation** – Remembers and restores your exact volume after ads
- 🔄 **Auto-Recovery** – Handles Spotify restarts, crashes, and edge cases gracefully

### 🎨 **Enhanced User Experience**  
- 🌈 **Rich Visual Interface** – Colorful terminal output with Unicode symbols
- 📊 **Real-time Statistics** – Track ads blocked, time saved, and session data
- 🔔 **Desktop Notifications** – Optional system notifications when ads are blocked/unblocked
- 📱 **Comprehensive CLI** – Multiple commands for status, testing, configuration, and more
- 🎛️ **Volume Fade Effects** – Smooth fade in/out transitions (optional)

### 🛠️ **Advanced Configuration**
- ⚙️ **Persistent Settings** – Save preferences in configuration file
- 📝 **Whitelist Support** – Prevent false positives by whitelisting artists/tracks
- 🎚️ **Adjustable Sensitivity** – Fine-tune detection with strict mode and custom thresholds
- 📋 **Multiple Audio Backends** – Supports PulseAudio (preferred) and ALSA (fallback)
- ⏱️ **Customizable Intervals** – Adjust checking frequency for performance vs. responsiveness

### 🔧 **Developer & Power User Features**
- 👥 **Daemon Mode** – Run as background service with systemd integration
- 📈 **Performance Monitoring** – Built-in caching and optimization for low resource usage
- 🧪 **Testing Tools** – Test ad detection on current track, volume controls, and more
- 📜 **Comprehensive Logging** – Detailed logs with automatic rotation
- 🔄 **Self-Management** – System-wide installation, auto-updates, and service management

### 🎵 **Smart Detection Methods**
- 🎯 **URL Pattern Matching** – Detects `spotify:ad:` and similar advertisement URLs
- 📝 **Metadata Analysis** – Checks title, artist, and album fields for ad indicators  
- ⏰ **Duration-Based Detection** – Identifies suspiciously short tracks typical of ads
- 🔍 **Multi-Layer Validation** – Combines multiple methods for accurate detection
- 🚫 **False Positive Prevention** – Whitelist system to avoid muting legitimate short songs

---

## 📦 Dependencies
Before running the script, make sure the following tools are installed:
### 🐧 Ubuntu / Debian
```bash
sudo apt update
sudo apt install playerctl pulseaudio-utils alsa-utils
```
### 🐧 Fedora
```bash
sudo dnf install playerctl pulseaudio-utils alsa-utils
```
### 🐧 Arch Linux
```bash
sudo pacman -S playerctl pulseaudio alsa-utils
```
---
## ✅ Verify Installation
Run these commands to ensure everything is working:
```bash
# Check playerctl
playerctl --version
# Check PulseAudio
pactl info
# Check ALSA
amixer --version
# Check if Spotify is detected
playerctl --list-all | grep spotify
```
---
## 🛠️ How It Works
The script uses `playerctl` to detect when an ad is playing.
When an ad is detected, it uses either `pactl` (PulseAudio) or `amixer` (ALSA) to mute your system volume. Once the ad ends, it unmutes automatically.

**Enhanced Detection Process:**
1. 📡 **Monitor Spotify** – Continuously checks track metadata and playback status
2. 🔍 **Multi-Method Analysis** – Uses URL patterns, metadata analysis, and duration checking
3. 🎯 **Smart Decision Making** – Applies whitelist rules and validation logic
4. 🔇 **Precise Audio Control** – Mutes only Spotify's audio stream (when possible)
5. 📊 **Statistics Tracking** – Records blocking data and performance metrics

---
## 🚀 Getting Started
First, clone the repository:
```bash
git clone https://github.com/basbassi-houssam/no_spotify_ads_linux
cd no_spotify_ads_linux
```
You'll find two main scripts:
* `NoSpotifyAds` – the main script that mutes/unmutes Spotify
* `SpotifyAdsBlocker` – optional script to monitor and launch `NoSpotifyAds` when Spotify starts

### 🎮 **Quick Start Commands**
```bash
# Basic usage with enhanced monitoring
./NoSpotifyAds

# Fast mode with minimal output
./NoSpotifyAds -i 0.5 --quiet

# Show current status and track info
./NoSpotifyAds status

# View blocking statistics
./NoSpotifyAds stats

# Test ad detection on current track
./NoSpotifyAds test

# Configure settings interactively
./NoSpotifyAds config save

# Add artist to whitelist (prevent false positives)
./NoSpotifyAds whitelist add "Artist Name"

# Run as background daemon
./NoSpotifyAds daemon start
```

---
## 🧩 Usage Options – Choose What Fits You 🫵
### 🔹 Option 1: Run Manually
Simple and fast. Just run the script whenever you launch Spotify:
```bash
./NoSpotifyAds
```

**Pro Tips:**
- Use `./NoSpotifyAds -i 0.5` for faster ad detection
- Add `--quiet` flag to reduce terminal output
- Run `./NoSpotifyAds stats` to see how many ads you've blocked!

---
### 🔹 Option 2: Auto-Start on Boot
#### 📁 For Desktop Environments (KDE, GNOME, XFCE, etc.)
1. Create a `.desktop` file in `~/.config/autostart/`:
```bash
nano ~/.config/autostart/no-spotify-ads.desktop
```
2. Paste this into the file (edit the `Exec` path):
```ini
[Desktop Entry]
Type=Application
Exec=/full/path/to/NoSpotifyAds --quiet
Hidden=true
NoDisplay=true
X-GNOME-Autostart-enabled=true
Name=NoSpotifyAds
Comment=Automatically mutes Spotify ads
```
> 🔸 Remove or comment out `X-GNOME-Autostart-enabled=true` if you're not using GNOME.

#### 🪟 For Window Managers (BSPWM, Hyprland, etc.)
Just add the script to your autostart section. For example:
**BSPWM**
```bash
# ~/.config/bspwm/bspwmrc
~/path/to/NoSpotifyAds --quiet &
```
**Hyprland**
```bash
# ~/.config/hypr/hyprland.conf
exec-once = ~/path/to/NoSpotifyAds --quiet
```
---
### 🔹 Option 3: Auto-Start Only When Spotify is Running
If you don't want the script running all the time, use the `SpotifyAdsBlocker` script.
This script waits for Spotify to launch, then runs `NoSpotifyAds`, and stops once Spotify closes.
#### Setup:
1. Make sure both scripts are in the same folder.
2. Autostart only `SpotifyAdsBlocker` instead of `NoSpotifyAds`.
Example for autostart (`.desktop` file or WM config):
```bash
/full/path/to/SpotifyAdsBlocker &
```

---
### 🔹 Option 4: System Service (Advanced)
Install as a system-wide service for automatic management:
```bash
# Install system-wide (requires sudo)
sudo ./NoSpotifyAds install

# Enable user service
systemctl --user enable nospotifyads

# Start service now
systemctl --user start nospotifyads

# Check service status
systemctl --user status nospotifyads
```

---

## 📊 **Command Reference**

| Command | Description | Example |
|---------|-------------|---------|
| `start` | Start monitoring (default) | `./NoSpotifyAds start --quiet` |
| `status` | Show current Spotify status | `./NoSpotifyAds status` |
| `stats` | Display blocking statistics | `./NoSpotifyAds stats` |
| `test` | Test ad detection | `./NoSpotifyAds test` |
| `config` | Manage configuration | `./NoSpotifyAds config save` |
| `whitelist` | Manage whitelist | `./NoSpotifyAds whitelist add "Artist"` |
| `volume` | Show volume information | `./NoSpotifyAds volume` |
| `daemon` | Background service control | `./NoSpotifyAds daemon start` |
| `log` | View logs | `./NoSpotifyAds log tail` |

### 🎛️ **Options**
- `-i, --interval SEC` – Set check interval (default: 0.75)
- `-q, --quiet` – Quiet mode (minimal output)
- `--no-notifications` – Disable desktop notifications  
- `--strict` – Enable strict ad detection
- `--fade` – Enable volume fade effects

---

## 🧪 **Advanced Usage Examples**

### 📈 **Performance Optimization**
```bash
# Ultra-fast detection (higher CPU usage)
./NoSpotifyAds -i 0.25

# Battery-friendly mode (slower detection)  
./NoSpotifyAds -i 2.0 --quiet
```

### 🎯 **Troubleshooting False Positives**
```bash
# Test current track detection
./NoSpotifyAds test

# Add problematic artist to whitelist
./NoSpotifyAds whitelist add "Short Song Artist"

# Enable strict mode for better accuracy
./NoSpotifyAds --strict
```

### 📊 **Monitoring and Statistics**
```bash
# View real-time statistics
watch -n 1 "./NoSpotifyAds stats"

# Check detailed logs
./NoSpotifyAds log tail

# View current Spotify volume and status
./NoSpotifyAds volume
```

---

## ☕ Support This Project
If this project helped you, consider supporting it to keep it alive and improved:
* ❤️ [Donate on Ko-fi](https://ko-fi.com/basbassihoussam)
* 💸 [Donate via PayPal](https://paypal.me/BasbassiHoussam)

Your support means a lot 🙏

---

## 🙋‍♂️ Questions? Suggestions?
Feel free to open an [issue](https://github.com/basbassi-houssam/no_spotify_ads_linux/issues) or submit a pull request.

### 📝 **Contributing**
We welcome contributions! Whether it's:
- 🐛 Bug fixes
- ✨ New features  
- 📚 Documentation improvements
- 🧪 Testing on different distributions
- 🎨 UI/UX enhancements

Check out our issues page or submit a pull request!
