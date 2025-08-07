# 🎵 Spotify Ad Muter for Linux

**Automatically mute Spotify advertisements on Linux systems**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-orange.svg)](https://www.kernel.org/)
[![GitHub stars](https://img.shields.io/github/stars/basbassi-houssam/no_spotify_ads_linux?style=social)](https://github.com/basbassi-houssam/no_spotify_ads_linux/stargazers)

## 🎥 Demo



https://github.com/user-attachments/assets/0fb9188f-4922-432a-b3a1-0123f7e399bb



## ✨ Features

- 🔇 **Automatic Ad Muting**: Detects and mutes Spotify ads instantly
- 🎛️ **Smart Audio Control**: Restores volume when music resumes
- 🚀 **Auto-Start**: Runs automatically when you log in
- 📊 **Low Resource Usage**: Minimal CPU and memory footprint
- 🔄 **Robust Monitoring**: Continues working even if Spotify restarts
- 🛠️ **Easy Management**: Simple systemd service integration
- 🔍 **Multi-Distribution Support**: Works on Ubuntu, Fedora, Arch, and more

## 🚀 Installation

### Prerequisites

Before installing, ensure your system meets these requirements:

- **OS**: Linux with systemd
- **Shell**: Bash 4.0 or later
- **Privileges**: sudo access (for system installation)
- **Network**: Internet connection (for initial download)

#### Required Dependencies

The installer will automatically detect and help install missing dependencies:

| Package | Purpose | Debian/Ubuntu | Fedora/RHEL | Arch/Manjaro |
|---------|---------|---------------|-------------|--------------|
| `playerctl` | Media player control | `playerctl` | `playerctl` | `playerctl` |
| `pulseaudio-utils` | Audio control | `pulseaudio-utils` | `pulseaudio-utils` | `pulseaudio` |
| `curl` | Download manager | `curl` | `curl` | `curl` |
| `systemd` | Service management | `systemd` | `systemd` | `systemd` |

#### Manual Dependency Installation

If you prefer to install dependencies manually:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y playerctl pulseaudio-utils curl systemd

# Fedora/RHEL/CentOS
sudo dnf install -y playerctl pulseaudio-utils curl systemd

# Arch/Manjaro
sudo pacman -S --noconfirm playerctl pulseaudio curl systemd

# openSUSE
sudo zypper install -y playerctl pulseaudio-utils curl systemd
```

### Quick Install (Recommended)

**One-line installation** - downloads and runs the installer automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/install.sh | bash
```

### Standard Installation

**Download first, then install** - for users who prefer to inspect scripts:

```bash
# Download the installer
curl -fsSL https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/install.sh -o install.sh

# Make it executable
chmod +x install.sh

# Run the installer
./install.sh
```

### Advanced Installation Options

The installer supports several options for different scenarios:

```bash
./install.sh                # Install normally (default)
./install.sh --install      # Same as default
./install.sh --fix          # Fix existing service configuration
./install.sh --test         # Test service configuration
./install.sh --debug        # Show system information
./install.sh --version      # Show script version
./install.sh --help         # Show detailed help
```

#### Debug Installation

If you encounter issues, use debug mode for detailed output:

```bash
# Enable debug output during installation
DEBUG=1 ./install.sh --debug

# Test the installation
./install.sh --test
```

### Manual Installation

If you prefer complete control over the installation process:

```bash
# 1. Download all required files
wget https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/install.sh
wget https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/uninstall.sh

# 2. Make scripts executable
chmod +x install.sh uninstall.sh

# 3. Check system requirements
./install.sh --debug

# 4. Install dependencies manually if needed
sudo apt install playerctl pulseaudio-utils curl  # Ubuntu/Debian

# 5. Run the installer
./install.sh
```

### What Gets Installed

The installation process will:

1. ✅ **Check system compatibility** and dependencies
2. ✅ **Download the latest ad muter script** from GitHub
3. ✅ **Install it system-wide** in `/usr/local/bin/no-spotify-ads`
4. ✅ **Create a systemd user service** in `~/.config/systemd/user/`
5. ✅ **Enable automatic startup** when you log in
6. ✅ **Start the service** immediately

#### Files Created

```
/usr/local/bin/no-spotify-ads                         # Main executable script
~/.config/systemd/user/no-spotify-ads.service         # Systemd user service
/usr/local/bin/no-spotify-ads.backup.YYYYMMDD_HHMMSS  # Backup files (if updating)
```

### Post-Installation

After successful installation:

1. **Service starts automatically** - no action needed
2. **Check status**: `systemctl --user status no-spotify-ads`
3. **View logs**: `journalctl --user -u no-spotify-ads -f`
4. **Open Spotify** - the ad muter will begin monitoring

## 🗑️ Uninstallation

### Quick Uninstall

If you used the installer, you should have the uninstall script:

```bash
./uninstall.sh
```

### Download Uninstaller

If you don't have the uninstall script, you can use one line command:

```bash
curl -fsSL https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/uninstall.sh | bash
```

Or if you want to do it manually:

```bash
# Download the uninstaller
curl -fsSL https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/uninstall.sh -o uninstall.sh

# Make it executable
chmod +x uninstall.sh

# Run the uninstaller
./uninstall.sh
```

### Uninstaller Options

```bash
./uninstall.sh              # Remove installation completely (default)
./uninstall.sh --uninstall  # Same as default
./uninstall.sh --version    # Show uninstaller version
./uninstall.sh --help       # Show uninstall help
```

### What Gets Removed

The uninstaller will:

1. 🛑 **Stop the running service**
2. 🔓 **Disable automatic startup**
3. 🗑️ **Remove the service file**
4. 🗑️ **Remove the main script**
5. 🗑️ **Optionally remove backup files**
6. 🔓 **Optionally disable user lingering**

#### Interactive Options

During uninstallation, you'll be asked:

- **Remove backup files?** - Choose `y` to delete all backup files
- **Disable user lingering?** - Choose `y` to disable auto-start services at boot

### Manual Uninstallation

If the uninstaller fails, you can remove files manually:

```bash
# Stop and disable the service
systemctl --user stop no-spotify-ads
systemctl --user disable no-spotify-ads

# Remove service file
rm -f ~/.config/systemd/user/no-spotify-ads.service

# Reload systemd daemon
systemctl --user daemon-reload

# Remove main script (requires sudo)
sudo rm -f /usr/local/bin/no-spotify-ads

# Remove backup files (optional)
sudo rm -f /usr/local/bin/no-spotify-ads.backup.*

# Remove lingering (optional)
sudo loginctl disable-linger $USER
```

### Verification

After uninstallation, verify removal:

```bash
# Check if service exists
systemctl --user status no-spotify-ads

# Check if files are gone
ls -la /usr/local/bin/no-spotify-ads
ls -la ~/.config/systemd/user/no-spotify-ads.service
```

Both commands should show "not found" or "no such file".

## 🎛️ Usage

### Automatic Operation

Once installed, the service runs automatically:

1. **Starts** when you log in
2. **Waits** for Spotify to launch
3. **Monitors** for advertisements
4. **Mutes** audio during ads
5. **Restores** volume when music resumes

### Manual Service Control

```bash
# Check service status
systemctl --user status no-spotify-ads

# Start the service
systemctl --user start no-spotify-ads

# Stop the service
systemctl --user stop no-spotify-ads

# Restart the service
systemctl --user restart no-spotify-ads

# View real-time logs
journalctl --user -u no-spotify-ads -f

# Enable/disable auto-start
systemctl --user enable no-spotify-ads
systemctl --user disable no-spotify-ads
```

### Direct Script Usage

```bash
# Run manually (for testing)
/usr/local/bin/no-spotify-ads

# Run with debug output
DEBUG=1 /usr/local/bin/no-spotify-ads

# Show help
/usr/local/bin/no-spotify-ads --help
```

## 🔧 Management Scripts

### Installation Script Options

```bash
./install.sh                # Install normally (default)
./install.sh --install      # Same as default
./install.sh --fix          # Fix existing service configuration
./install.sh --test         # Test service configuration
./install.sh --debug        # Show system information
./install.sh --version      # Show script version
./install.sh --help         # Show help
```

### Uninstallation Script Options

```bash
./uninstall.sh             # Remove installation completely
./uninstall.sh --help      # Show uninstall help
```

## 🐛 Troubleshooting

### Common Issues

#### Service Not Starting
```bash
# Check service status
systemctl --user status no-spotify-ads

# Check logs for errors
journalctl --user -u no-spotify-ads --no-pager -l

# Try fixing the service
./install.sh --fix
```

#### Permission Issues
```bash
# Ensure proper permissions
ls -la /usr/local/bin/no-spotify-ads
ls -la ~/.config/systemd/user/no-spotify-ads.service

# Fix permissions if needed
./install.sh --fix
```

#### Dependencies Missing
```bash
# Check what's installed
./install.sh --debug

# Install missing packages (example for Ubuntu)
sudo apt update && sudo apt install playerctl pulseaudio-utils curl
```

### Debug Mode

Enable debug output for detailed information:

```bash
# Debug installation
DEBUG=1 ./install.sh --debug

# Debug service
DEBUG=1 systemctl --user start no-spotify-ads
journalctl --user -u no-spotify-ads -f
```

### Important Notes

- ⚠️ **Always use `systemctl --user`** (NOT `sudo systemctl`)
- ⚠️ **The service runs as your user**, not as root
- ⚠️ **Requires active desktop session** with audio system running
- ⚠️ **Works with Spotify desktop client**, not web player

## 📁 Files Created

The installation creates these files:

```
/usr/local/bin/no-spotify-ads                    # Main executable script
~/.config/systemd/user/no-spotify-ads.service    # Systemd user service
```

Backups are automatically created during installation and updates:
```
/usr/local/bin/no-spotify-ads.backup.YYYYMMDD_HHMMSS
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🐛 **Report bugs** by opening an issue
2. 💡 **Suggest features** or improvements
3. 🔧 **Submit pull requests** with fixes or enhancements
4. 📖 **Improve documentation**
5. ⭐ **Star this repository** if you find it useful!

### Development Setup

```bash
git clone https://github.com/basbassi-houssam/no_spotify_ads_linux.git
cd no_spotify_ads_linux

# Test the installation script
./install.sh --test

# Run in debug mode
DEBUG=1 ./install.sh --debug
```

## ⭐ Star This Repository

If this project helped you enjoy ad-free Spotify, please consider starring it!

[![GitHub stars](https://img.shields.io/github/stars/basbassi-houssam/no_spotify_ads_linux?style=social)](https://github.com/basbassi-houssam/no_spotify_ads_linux/stargazers)

**[⭐ Star this repo on GitHub](https://github.com/basbassi-houssam/no_spotify_ads_linux)**

## 💖 Support This Project

If you find this project useful, consider supporting its development:

* ❤️ [Donate on Ko-fi](https://ko-fi.com/basbassihoussam)
* 💸 [Donate via PayPal](https://paypal.me/BasbassiHoussam)

Your support helps maintain and improve this project!

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE.md](LICENSE.md) file for details.

### What this means:
- ✅ You can use, modify, and distribute this software
- ✅ You can use it for commercial purposes  
- ✅ You can create proprietary derivatives
- ✅ Very permissive - minimal restrictions
- ⚠️ You must include the original copyright notice
- ⚠️ Software is provided "as is" without warranty

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/basbassi-houssam/no_spotify_ads_linux/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/basbassi-houssam/no_spotify_ads_linux/discussions)
- 📧 **Email**: [Contact the author](mailto:basbassi.houssam@gmail.com)

## 🎯 Roadmap

- [ ] GUI configuration tool
- [ ] Support for other music streaming services
- [ ] Whitelist/blacklist for specific ad types
- [ ] Integration with desktop notifications
- [ ] Snap/Flatpak/AppImage packages
- [ ] Automatic updates mechanism

## 🙏 Acknowledgments

- Thanks to all contributors and users who test and improve this project
- Special thanks to the open-source community for tools like `playerctl` and `systemd`
- Inspired by similar projects for other platforms

---

**Made with ❤️ by [Houssam Basbassi](https://github.com/basbassi-houssam)**

*Enjoy your ad-free Spotify experience on Linux! 🎵*
