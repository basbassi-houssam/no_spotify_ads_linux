# 🎵 Mute Spotify Ads Automatically (Shell Script)

Tired of annoying Spotify ads breaking your vibe? This shell script automatically **mutes Spotify during ads** and restores the volume when your music comes back.

> ✅ Works with the **Spotify desktop app** only (not the web player).

---

## 📦 Dependencies

Before running the script, make sure you have the following tools installed:

### 🐧 Ubuntu / Debian (Full Setup)

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

Run the following commands to confirm everything is installed properly:

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

The script uses `playerctl` to detect when an ad is playing, then uses either `pactl` (PulseAudio) or `amixer` (ALSA) to mute the volume. When the ad is over, it unmutes automatically.

## There are three ways to use this script and it depends on you 🫵:

But before you must get the shell script:

```bash
git clone https://github.com/basbassi-houssam/no_spotify_ads_linux
```

### Option One:

Run the script maunually every time you launch Spotify. (Simple and easy)

### Option Two:

#### Set the script to auto start:

To set the shell script to auto start, it depends on you DE or WM, However I'm going to show you the way that works for most DE and WM:

First, You must create a desktop file in (~/.config/autostart) that auto starts when system boots up:

Let make a file name it no-spotify-ads.desktop in ~/.config/autostart/:

```bash
[Desktop Entry]
Type=Shell
Exec=/path/to/your/NoSpotifyAds
Hidden=true
NoDisplay=true
X-GNOME-Autostart-enabled=true # Comment/remove this if you're not using gnome
Name=NoSpotifyAds
Comment=Autostart MyApp at login
```



