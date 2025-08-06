<meta name="linux spotify">
<meta name="block spotify ads">
<meta name="no spotify ads">
<meta name="spotify muter">
# 🎵 Spotify Ad Muter for Linux

**Automatically mutes Spotify audio during advertisements while keeping them playing in the background.**

This lightweight script monitors your Spotify client and intelligently mutes only the audio during ads, allowing them to complete normally while restoring sound when your music resumes.

## ✨ Features

- 🔇 **Audio-only muting** - Ads play silently while music audio is restored
- 🎯 **Precise detection** - Uses multiple methods to identify advertisements
- 🔄 **Auto-restart** - Continues monitoring even when Spotify is closed and reopened  
- ⚡ **Lightweight** - Minimal system resource usage
- 🔧 **PulseAudio support** - Mutes only Spotify, not your entire system
- 🐧 **Systemd integration** - Runs automatically at startup
- 📊 **Real-time status** - Visual feedback showing current track status

## 🚀 Quick Install

**One-line installation:**

```bash
curl -fsSL https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/install.sh | bash
```

Or manually:

```bash
wget https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/install.sh
chmod +x install.sh
./install.sh
```

## 📋 Requirements

### Required Dependencies

- **playerctl** - For Spotify media control
- **pulseaudio-utils** (pactl) - For precise audio control *(recommended)*
- **alsa-utils** (amixer) - Fallback audio control
- **curl** or **wget** - For downloading the script

### Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install playerctl pulseaudio-utils curl
```

**Fedora:**
```bash
sudo dnf install playerctl pulseaudio-utils curl
```

**Arch Linux:**
```bash
sudo pacman -S playerctl pulseaudio curl
```

## 🔧 Installation Methods

### Method 1: Automatic Installation (Recommended)

1. **Download and run the installer:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/install.sh | bash
   ```

2. **The installer will:**
   - Check and install dependencies
   - Download the latest script
   - Install it system-wide in `/usr/local/bin`
   - Create a systemd user service
   - Enable automatic startup

### Method 2: Manual Installation

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/NoSpotifyAds
   chmod +x NoSpotifyAds
   ```

2. **Install system-wide:**
   ```bash
   sudo cp NoSpotifyAds /usr/local/bin/no-spotify-ads
   ```

3. **Run manually or set up your own service**

## 🎮 Usage

### Automatic Operation (After Installation)

The service starts automatically when you log in and begins monitoring when Spotify is running.

### Manual Control Commands

```bash
# Service control (use systemctl --user, NOT sudo)
systemctl --user start no-spotify-ads     # Start the service
systemctl --user stop no-spotify-ads      # Stop the service  
systemctl --user restart no-spotify-ads   # Restart the service
systemctl --user status no-spotify-ads    # Check service status

# View logs
journalctl --user -u no-spotify-ads -f    # Follow live logs
journalctl --user -u no-spotify-ads       # View all logs

# Direct script usage
no-spotify-ads                 # Run manually
no-spotify-ads --help          # Show help
no-spotify-ads --status        # Show current status
no-spotify-ads --test          # Test ad detection
no-spotify-ads --volume        # Show volume info
```

### Installer Options

```bash
./install.sh              # Install normally
./install.sh --uninstall  # Remove installation
./install.sh --fix        # Fix service configuration
./install.sh --test       # Test service setup
./install.sh --help       # Show installer help
```

## 🔍 How It Works

1. **Monitoring**: The script continuously monitors Spotify using `playerctl`
2. **Detection**: Uses multiple methods to identify ads:
   - Track URL patterns (`spotify:ad:*`)
   - Metadata analysis (title, artist, album)
   - Duration analysis (ads are typically 15-30 seconds)
   - Empty or suspicious metadata patterns
3. **Audio Control**: 
   - **PulseAudio**: Mutes only Spotify's audio stream (precise)
   - **ALSA**: Falls back to system volume control if needed
4. **Restoration**: Automatically restores audio when music resumes

## 🐛 Troubleshooting

### Common Issues

**Service won't start:**
```bash
# Fix service configuration
./install.sh --fix

# Check logs for errors
journalctl --user -u no-spotify-ads
```

**Permission denied:**
- Never use `sudo` with `systemctl --user` commands
- The script should NOT be run as root

**Dependencies missing:**
```bash
# Check what's installed
playerctl --version
pactl --version
```

**Spotify not detected:**
- Make sure Spotify is actually running
- Try: `playerctl --player=spotify status`

### Logs and Debugging

- **Live logs**: `journalctl --user -u no-spotify-ads -f`
- **Script logs**: `/tmp/spotify-ad-muter.log`
- **Test detection**: `no-spotify-ads --test`
- **Service status**: `systemctl --user status no-spotify-ads`

## ⚙️ Configuration

### Adjusting Check Interval

Edit the service or run manually with custom interval:

```bash
no-spotify-ads -i 2  # Check every 2 seconds instead of 1
```

### Audio Method Priority

1. **PulseAudio** (`pactl`) - Preferred, mutes only Spotify
2. **ALSA** (`amixer`) - Fallback, mutes system volume

## 🆚 Comparison with Other Solutions

| Method | This Script | Browser Extensions | System-wide Blockers |
|--------|-------------|-------------------|---------------------|
| Works with Desktop App | ✅ | ❌ | ✅ |
| Preserves Ad Completion | ✅ | ❌ | ❌ |
| Audio-only Muting | ✅ | N/A | ❌ |
| No Breaking Changes | ✅ | ❌ | ❌ |
| Lightweight | ✅ | ✅ | ❌ |

## 🔒 Privacy & Security

- **No network connections** - Works entirely offline
- **No data collection** - Only monitors local Spotify instance
- **Open source** - Full code transparency
- **Minimal permissions** - Only needs audio control access

## 🤝 Contributing

Contributions are welcome! Please feel free to:

- Report bugs via GitHub issues
- Submit feature requests
- Create pull requests
- Improve documentation

## 💝 Support This Project

If you find this project helpful, consider supporting its development:

* ❤️ [Donate on Ko-fi](https://ko-fi.com/basbassihoussam)
* 💸 [Donate via PayPal](https://paypal.me/BasbassiHoussam)

Your support helps maintain and improve this project!

## 📄 License

This project is open source. Feel free to use, modify, and distribute according to the license terms.

## 🔄 Updates

The installer automatically downloads the latest version. To update manually:

```bash
./install.sh  # Reinstall with latest version
```

## ⭐ Star This Repo

If this project helped you, please consider giving it a star on GitHub!

---

**Tested on:** Ubuntu, Fedora, Arch Linux, and derivatives  
**Spotify Version:** Compatible with current Spotify desktop client  
**Maintained by:** [BasbassiHoussam](https://github.com/basbassi-houssam)
