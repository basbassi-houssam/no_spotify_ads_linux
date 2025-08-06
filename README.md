# 🎵 Mute Spotify Ads Automatically – Shell Script for Linux

Tired of annoying Spotify ads interrupting your music? This lightweight shell script automatically **mutes Spotify during ads** and **restores the volume once the ad ends**.

> ✅ Works with the **Spotify Desktop App only** (not the web player).
> ⚡ Supports most Linux distributions.

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

---

## 🚀 Getting Started

First, clone the repository:

```bash
git clone https://github.com/basbassi-houssam/no_spotify_ads_linux
cd no_spotify_ads_linux
```

You’ll find two main scripts:

* `NoSpotifyAds` – the main script that mutes/unmutes Spotify
* `SpotifyAdsBlocker` – optional script to monitor and launch `NoSpotifyAds` when Spotify starts

---

## 🧩 Usage Options – Choose What Fits You 🫵

### 🔹 Option 1: Run Manually

Simple and fast. Just run the script whenever you launch Spotify:

```bash
./NoSpotifyAds
```

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
Exec=/full/path/to/NoSpotifyAds
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
~/path/to/NoSpotifyAds &
```

**Hyprland**

```bash
# ~/.config/hypr/hyprland.conf
exec-once = ~/path/to/NoSpotifyAds
```

---

### 🔹 Option 3: Auto-Start Only When Spotify is Running

If you don’t want the script running all the time, use the `SpotifyAdsBlocker` script.

This script waits for Spotify to launch, then runs `NoSpotifyAds`, and stops once Spotify closes.

#### Setup:

1. Make sure both scripts are in the same folder.
2. Autostart only `SpotifyAdsBlocker` instead of `NoSpotifyAds`.

Example for autostart (`.desktop` file or WM config):

```bash
/full/path/to/SpotifyAdsBlocker &
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

