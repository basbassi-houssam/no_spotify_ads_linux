#!/bin/bash

# Spotify Ad Muter Installation Script
# This script installs the NoSpotifyAds script system-wide

set -e

# Configuration
SCRIPT_NAME="no-spotify-ads"
INSTALL_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"
SCRIPT_URL="https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/NoSpotifyAds"
SERVICE_NAME="no-spotify-ads"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_error "It needs to install system-wide but run as your user."
        print_error "Please run without sudo. The script will ask for sudo when needed."
        exit 1
    fi
}

# Check if user has sudo access
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        print_status "This script requires sudo access for system installation."
        print_status "You may be prompted for your password."
    fi
}

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for required commands
    if ! command -v playerctl >/dev/null 2>&1; then
        missing_deps+=("playerctl")
    fi
    
    if ! command -v pactl >/dev/null 2>&1 && ! command -v amixer >/dev/null 2>&1; then
        missing_deps+=("pulseaudio-utils or alsa-utils")
    fi
    
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing_deps+=("curl or wget")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo
        print_status "Install them with:"
        echo "  Ubuntu/Debian: sudo apt update && sudo apt install playerctl pulseaudio-utils curl"
        echo "  Fedora: sudo dnf install playerctl pulseaudio-utils curl"
        echo "  Arch: sudo pacman -S playerctl pulseaudio curl"
        exit 1
    fi
    
    print_success "All dependencies are installed"
}

# Download the script
download_script() {
    local temp_script="/tmp/$SCRIPT_NAME"
    
    print_status "Downloading Spotify Ad Muter script..."
    
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$SCRIPT_URL" -o "$temp_script"; then
            print_error "Failed to download script with curl"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q "$SCRIPT_URL" -O "$temp_script"; then
            print_error "Failed to download script with wget"
            return 1
        fi
    else
        print_error "Neither curl nor wget available"
        return 1
    fi
    
    # Verify the script was downloaded and is not empty
    if [[ ! -s "$temp_script" ]]; then
        print_error "Downloaded script is empty or doesn't exist"
        return 1
    fi
    
    # Make it executable
    chmod +x "$temp_script"
    
    print_success "Script downloaded successfully"
}

# Install the script
install_script() {
    local temp_script="$1"
    local target="$INSTALL_DIR/$SCRIPT_NAME"
    
    print_status "Installing script to $target..."
    
    # Copy script to install directory
    if ! sudo cp "$temp_script" "$target"; then
        print_error "Failed to copy script to $target"
        return 1
    fi
    
    # Set proper permissions
    if ! sudo chmod 755 "$target"; then
        print_error "Failed to set permissions on $target"
        return 1
    fi
    
    # Clean up temp file
    rm -f "$temp_script"
    
    print_success "Script installed to $target"
}

# Create systemd user service
create_user_service() {
    local service_file="$HOME/.config/systemd/user/$SERVICE_NAME.service"
    local service_dir="$(dirname "$service_file")"
    
    print_status "Creating systemd user service..."
    
    # Create user systemd directory if it doesn't exist
    mkdir -p "$service_dir"
    
    # Get the current user's UID for the service
    local user_id=$(id -u)
    
    # Create the service file
    cat > "$service_file" << EOF
[Unit]
Description=Spotify Ad Muter
After=graphical-session.target pulseaudio.service
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/$SCRIPT_NAME
Restart=always
RestartSec=5
Environment=DISPLAY=:0
Environment=PULSE_SERVER=unix:/run/user/$user_id/pulse/native
Environment=XDG_RUNTIME_DIR=/run/user/$user_id

# Restart policy
StartLimitIntervalSec=60
StartLimitBurst=3

[Install]
WantedBy=default.target
EOF
    
    print_success "User service created at $service_file"
}

# Enable and start the service
enable_service() {
    print_status "Enabling and starting the user service..."
    
    # Reload systemd user daemon
    if ! systemctl --user daemon-reload; then
        print_error "Failed to reload systemd user daemon"
        return 1
    fi
    
    # Enable the service
    if ! systemctl --user enable "$SERVICE_NAME.service"; then
        print_error "Failed to enable user service"
        return 1
    fi
    
    # Enable user lingering (allows service to start at boot without login)
    if ! sudo loginctl enable-linger "$USER"; then
        print_warning "Failed to enable user lingering - service may not start at boot"
    fi
    
    print_success "Service enabled for automatic startup"
}

# Start the service
start_service() {
    print_status "Starting the service..."
    
    # Start the service
    if systemctl --user start "$SERVICE_NAME.service"; then
        print_success "Service started successfully"
        
        # Wait a moment for the service to initialize
        sleep 2
        
        # Show service status
        echo
        print_status "Service status:"
        systemctl --user status "$SERVICE_NAME.service" --no-pager -l
        
    else
        print_warning "Service failed to start"
        print_status "Checking service status for more details..."
        echo
        systemctl --user status "$SERVICE_NAME.service" --no-pager -l || true
        echo
        print_status "You can check the logs with:"
        print_status "journalctl --user -u $SERVICE_NAME.service -f"
    fi
}

# Show usage instructions
show_usage() {
    echo
    print_success "Installation completed!"
    echo
    echo "Usage:"
    echo "  The service will automatically start monitoring when you log in"
    echo "  It will wait for Spotify to start and then monitor for ads"
    echo
    echo "Manual control:"
    echo "  Start:   systemctl --user start $SERVICE_NAME"
    echo "  Stop:    systemctl --user stop $SERVICE_NAME"
    echo "  Restart: systemctl --user restart $SERVICE_NAME"
    echo "  Status:  systemctl --user status $SERVICE_NAME"
    echo "  Logs:    journalctl --user -u $SERVICE_NAME -f"
    echo
    echo "Direct script usage:"
    echo "  Run manually: $INSTALL_DIR/$SCRIPT_NAME"
    echo "  Show help:    $INSTALL_DIR/$SCRIPT_NAME --help"
    echo "  Test mode:    $INSTALL_DIR/$SCRIPT_NAME --test"
    echo
    echo "The script will:"
    echo "  - Wait for Spotify to start if it's not running"
    echo "  - Mute Spotify audio during advertisements"
    echo "  - Restore audio when music resumes"
    echo "  - Continue monitoring even if Spotify is restarted"
    echo
    print_status "Note: Use 'systemctl --user' commands, not 'sudo systemctl'"
}

# Test service configuration
test_service() {
    print_status "Testing service configuration..."
    
    local service_file="$HOME/.config/systemd/user/$SERVICE_NAME.service"
    
    if [[ ! -f "$service_file" ]]; then
        print_error "Service file not found at $service_file"
        return 1
    fi
    
    # Test if the service file is valid
    if systemctl --user daemon-reload 2>/dev/null; then
        print_success "Service file syntax is valid"
    else
        print_error "Service file has syntax errors"
        return 1
    fi
    
    # Check if the script exists and is executable
    if [[ -x "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        print_success "Main script is installed and executable"
    else
        print_error "Main script not found or not executable at $INSTALL_DIR/$SCRIPT_NAME"
        return 1
    fi
    
    return 0
}

# Uninstall function
uninstall() {
    print_status "Uninstalling Spotify Ad Muter..."
    
    # Stop and disable service
    if systemctl --user is-enabled "$SERVICE_NAME.service" >/dev/null 2>&1; then
        systemctl --user stop "$SERVICE_NAME.service" 2>/dev/null || true
        systemctl --user disable "$SERVICE_NAME.service" 2>/dev/null || true
        print_success "Service stopped and disabled"
    fi
    
    # Remove service file
    local service_file="$HOME/.config/systemd/user/$SERVICE_NAME.service"
    if [[ -f "$service_file" ]]; then
        rm -f "$service_file"
        systemctl --user daemon-reload
        print_success "Service file removed"
    fi
    
    # Remove script
    local script_file="$INSTALL_DIR/$SCRIPT_NAME"
    if [[ -f "$script_file" ]]; then
        sudo rm -f "$script_file"
        print_success "Script removed from $script_file"
    fi
    
    # Disable user lingering
    sudo loginctl disable-linger "$USER" 2>/dev/null || true
    
    print_success "Uninstallation completed"
}

# Fix existing installation
fix_service() {
    print_status "Fixing existing service configuration..."
    
    # Stop the service if it's running
    systemctl --user stop "$SERVICE_NAME.service" 2>/dev/null || true
    
    # Recreate the service file
    create_user_service
    
    # Reload and try to enable again
    systemctl --user daemon-reload
    systemctl --user enable "$SERVICE_NAME.service"
    
    # Test the configuration
    if test_service; then
        print_success "Service configuration fixed"
        start_service
    else
        print_error "Service configuration still has issues"
        return 1
    fi
}

# Main installation function
main() {
    echo "Spotify Ad Muter - Installation Script"
    echo "======================================"
    echo
    
    check_root
    check_sudo
    check_dependencies
    
    # Download the script
    if ! download_script; then
        print_error "Failed to download script"
        exit 1
    fi
    
    local temp_script="/tmp/$SCRIPT_NAME"
    install_script "$temp_script"
    create_user_service
    enable_service
    
    # Test the service before starting
    if test_service; then
        start_service
    else
        print_error "Service configuration test failed"
        exit 1
    fi
    
    show_usage
}

# Command line argument handling
case "${1:-}" in
    --uninstall)
        uninstall
        exit 0
        ;;
    --fix)
        fix_service
        exit 0
        ;;
    --test)
        test_service
        exit $?
        ;;
    --help|-h)
        echo "Spotify Ad Muter Installation Script"
        echo
        echo "Usage:"
        echo "  $0              Install the Spotify ad muter"
        echo "  $0 --uninstall  Remove the installation"
        echo "  $0 --fix        Fix existing service configuration"
        echo "  $0 --test       Test service configuration"
        echo "  $0 --help       Show this help"
        echo
        echo "This script will:"
        echo "  1. Check and install dependencies"
        echo "  2. Download the latest script from GitHub"
        echo "  3. Install it system-wide in $INSTALL_DIR"
        echo "  4. Create a systemd user service"
        echo "  5. Enable automatic startup"
        echo
        echo "Common issues:"
        echo "  - Use 'systemctl --user' commands, not 'sudo systemctl'"
        echo "  - If service fails, try: $0 --fix"
        echo "  - Check logs with: journalctl --user -u $SERVICE_NAME -f"
        echo
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
