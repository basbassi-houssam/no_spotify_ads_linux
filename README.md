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

---

Let me know if you'd like me to:

* Add usage instructions
* Include an example script
* Make an install script
* Or format this as a Markdown file for you directly

Your call.
