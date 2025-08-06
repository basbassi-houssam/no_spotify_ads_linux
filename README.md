# Hello There

 Since lot of you listen to music and hate the advertisements, I made a shell script that mute Spotify
 Untill the ad is gone.

 This shell script does work on Spotify (App) Not Spotify Web Player.

 # Installation
 There are some depencencies that must be installed before trying the shell script

 Ubuntu/Debian (Complete setup):

sudo apt update
sudo apt install playerctl pulseaudio-utils alsa-utils

Fedora:

sudo dnf install playerctl pulseaudio-utils alsa-utils

Arch Linux:

sudo pacman -S playerctl pulseaudio alsa-utils

Verification Commands
Check if dependencies are installed:

# Check playerctl
playerctl --version

# Check PulseAudio tools
pactl info

# Check ALSA tools  
amixer --version

# Check if Spotify is detectable
playerctl --list-all | grep spotify












