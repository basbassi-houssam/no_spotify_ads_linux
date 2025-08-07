#!/bin/bash

# Spotify Ad Muter Installation Script
# This script installs the NoSpotifyAds script system-wide
# Version: 2.0

set -euo pipefail
IFS=$'\n\t'

# Configuration
readonly SCRIPT_NAME="no-spotify-ads"
readonly INSTALL_DIR="/usr/local/bin"
readonly SCRIPT_URL="https://raw.githubusercontent.com/basbassi-houssam/no_spotify_ads_linux/main/NoSpotifyAds"
readonly SERVICE_NAME="no-spotify-ads"
readonly MIN_BASH_VERSION=4
readonly SCRIPT_VERSION="2.0"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global variables
TEMP_FILES=()
SERVICE_FILE=""

# Cleanup function
cleanup() {
    local exit_code=$?
    
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        print_status "Cleaning up temporary files..."
        for file in "${TEMP_FILES[@]}"; do
            [[ -f "$file" ]] && rm -f "$file"
        done
    fi
    
    if [[ $exit_code -ne 0 ]]; then
        print_error "Installation failed with exit code $exit_code"
        echo
        print_status "If you need help, check the logs or create an issue on GitHub"
    fi
    
    exit $exit_code
}

# Set up signal handlers
trap cleanup EXIT
trap 'cleanup' INT TERM

# Print colored output functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_debug() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1" >&2
    fi
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# Version and compatibility checks
check_bash_version() {
    if [[ ${BASH_VERSION%%.*} -lt $MIN_BASH_VERSION ]]; then
        print_error "This script requires Bash $MIN_BASH_VERSION or later"
        print_error "Current version: $BASH_VERSION"
        exit 1
    fi
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
    print_status "Checking sudo access..."
    
    if ! command -v sudo >/dev/null 2>&1; then
        print_error "sudo command not found. Please install sudo or run as root."
        exit 1
    fi
    
    if ! sudo -n true 2>/dev/null; then
        print_status "This script requires sudo access for system installation."
        print_status "You may be prompted for your password."
        
        # Test sudo with a simple command
        if ! sudo true; then
            print_error "Cannot obtain sudo privileges"
            exit 1
        fi
    fi
    
    print_success "Sudo access confirmed"
}

# Detect Linux distribution
detect_distro() {
    local distro="unknown"
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        distro="$ID"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        distro="${DISTRIB_ID,,}"
    elif command -v lsb_release >/dev/null 2>&1; then
        distro="$(lsb_release -si | tr '[:upper:]' '[:lower:]')"
    fi
    
    echo "$distro"
}

# Get package manager install command
get_install_cmd() {
    local distro="$1"
    
    case "$distro" in
        ubuntu|debian|linuxmint|pop)
            echo "sudo apt update && sudo apt install -y"
            ;;
        fedora|centos|rhel|rocky|almalinux)
            echo "sudo dnf install -y"
            ;;
        opensuse*|sles)
            echo "sudo zypper install -y"
            ;;
        arch|manjaro|endeavouros)
            echo "sudo pacman -S --noconfirm"
            ;;
        gentoo)
            echo "sudo emerge -av"
            ;;
        alpine)
            echo "sudo apk add"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Check dependencies with better distribution support
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    local distro
    distro="$(detect_distro)"
    
    # Check for required commands
    local deps=(
        "playerctl:playerctl"
        "curl:curl" 
        "systemctl:systemd"
    )
    
    # Check audio system (either PulseAudio or ALSA)
    if ! command -v pactl >/dev/null 2>&1 && ! command -v amixer >/dev/null 2>&1; then
        case "$distro" in
            ubuntu|debian|linuxmint|pop)
                missing_deps+=("pulseaudio-utils")
                ;;
            fedora|centos|rhel|rocky|almalinux)
                missing_deps+=("pulseaudio-utils")
                ;;
            arch|manjaro|endeavouros)
                missing_deps+=("pulseaudio")
                ;;
            *)
                missing_deps+=("pulseaudio-utils")
                ;;
        esac
    fi
    
    # Check other dependencies
    for dep in "${deps[@]}"; do
        local cmd="${dep%%:*}"
        local pkg="${dep##*:}"
        
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$pkg")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies:"
        printf "  - %s\n" "${missing_deps[@]}"
        echo
        
        local install_cmd
        install_cmd="$(get_install_cmd "$distro")"
        
        if [[ -n "$install_cmd" ]]; then
            print_status "Install them with:"
            echo "  $install_cmd ${missing_deps[*]}"
        else
            print_warning "Unknown distribution. Please install the missing packages manually."
            print_status "Distribution detected: $distro"
        fi
        
        echo
        print_status "Common package names by distribution:"
        echo "  Ubuntu/Debian: playerctl pulseaudio-utils curl systemd"
        echo "  Fedora/RHEL:   playerctl pulseaudio-utils curl systemd"
        echo "  Arch/Manjaro:  playerctl pulseaudio curl systemd"
        echo "  openSUSE:      playerctl pulseaudio-utils curl systemd"
        
        read -p "Would you like to try installing dependencies automatically? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] && [[ -n "$install_cmd" ]]; then
            print_status "Installing dependencies..."
            if eval "$install_cmd ${missing_deps[*]}"; then
                print_success "Dependencies installed successfully"
            else
                print_error "Failed to install dependencies automatically"
                exit 1
            fi
        else
            exit 1
        fi
    fi
    
    print_success "All dependencies are installed"
}

# Validate URL and check connectivity
validate_url() {
    local url="$1"
    
    print_status "Validating download URL..."
    
    if ! curl -fsSL --connect-timeout 10 --max-time 30 -I "$url" >/dev/null 2>&1; then
        print_error "Cannot reach download URL: $url"
        print_error "Please check your internet connection or try again later"
        return 1
    fi
    
    print_success "Download URL is accessible"
    return 0
}

# Download the script with better error handling and validation
download_script() {
    local temp_script="/tmp/${SCRIPT_NAME}.$$"
    TEMP_FILES+=("$temp_script")
    
    print_status "Downloading Spotify Ad Muter script..."
    
    # Validate URL first
    if ! validate_url "$SCRIPT_URL"; then
        return 1
    fi
    
    # Download with better error handling
    local download_success=false
    local max_retries=3
    local retry_count=0
    
    while [[ $retry_count -lt $max_retries ]]; do
        if curl -fsSL --connect-timeout 10 --max-time 60 "$SCRIPT_URL" -o "$temp_script"; then
            download_success=true
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "Download attempt $retry_count failed, retrying..."
                sleep 2
            fi
        fi
    done
    
    if [[ "$download_success" != "true" ]]; then
        print_error "Failed to download script after $max_retries attempts"
        return 1
    fi
    
    # Verify the script was downloaded and is not empty
    if [[ ! -s "$temp_script" ]]; then
        print_error "Downloaded script is empty"
        return 1
    fi
    
    # Basic validation - check if it looks like a script
    if ! head -n 1 "$temp_script" | grep -q "^#!"; then
        print_error "Downloaded file doesn't appear to be a script"
        return 1
    fi
    
    # Check script size (should be reasonable)
    local file_size
    file_size="$(stat -f%z "$temp_script" 2>/dev/null || stat -c%s "$temp_script" 2>/dev/null || echo "0")"
    if [[ $file_size -lt 100 ]]; then
        print_error "Downloaded script appears to be too small ($file_size bytes)"
        return 1
    fi
    
    # Make it executable
    chmod +x "$temp_script"
    
    print_success "Script downloaded successfully (${file_size} bytes)"
    echo "$temp_script"
}

# Install the script with backup capability
install_script() {
    local temp_script="$1"
    local target="$INSTALL_DIR/$SCRIPT_NAME"
    
    print_status "Installing script to $target..."
    
    # Create backup if file already exists
    if [[ -f "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Creating backup at $backup"
        if ! sudo cp "$target" "$backup"; then
            print_warning "Failed to create backup"
        else
            print_success "Backup created"
        fi
    fi
    
    # Ensure install directory exists
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_status "Creating install directory $INSTALL_DIR"
        if ! sudo mkdir -p "$INSTALL_DIR"; then
            print_error "Failed to create install directory"
            return 1
        fi
    fi
    
    # Copy script to install directory
    if ! sudo cp "$temp_script" "$target"; then
        print_error "Failed to copy script to $target"
        return 1
    fi
    
    # Set proper permissions and ownership
    if ! sudo chmod 755 "$target"; then
        print_error "Failed to set permissions on $target"
        return 1
    fi
    
    if ! sudo chown root:root "$target"; then
        print_warning "Failed to set ownership (continuing anyway)"
    fi
    
    print_success "Script installed to $target"
}

# Create systemd user service with better configuration
create_user_service() {
    SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE_NAME.service"
    local service_dir
    service_dir="$(dirname "$SERVICE_FILE")"
    
    print_status "Creating systemd user service..."
    
    # Create user systemd directory if it doesn't exist
    if ! mkdir -p "$service_dir"; then
        print_error "Failed to create service directory"
        return 1
    fi
    
    # Get the current user's UID and XDG_RUNTIME_DIR
    local user_id
    user_id="$(id -u)"
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$user_id}"
    
    # Create the service file with improved configuration
    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Spotify Ad Muter
Documentation=https://github.com/basbassi-houssam/no_spotify_ads_linux
After=graphical-session.target pulseaudio.service pipewire.service
Wants=graphical-session.target
ConditionEnvironment=DISPLAY

[Service]
Type=simple
ExecStart=$INSTALL_DIR/$SCRIPT_NAME
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=5
TimeoutStartSec=30
TimeoutStopSec=10

# Environment
Environment=DISPLAY=:0
Environment=PULSE_SERVER=unix:$runtime_dir/pulse/native
Environment=XDG_RUNTIME_DIR=$runtime_dir
Environment=HOME=$HOME
Environment=USER=$USER

# Security and resource limits
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=$runtime_dir
MemoryHigh=100M
MemoryMax=200M
CPUQuota=50%

# Restart policy
StartLimitIntervalSec=120
StartLimitBurst=3

[Install]
WantedBy=default.target
EOF
    
    print_success "User service created at $SERVICE_FILE"
}

# Enable and start the service with better error handling
enable_service() {
    print_status "Configuring systemd user service..."
    
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
    if sudo loginctl enable-linger "$USER" 2>/dev/null; then
        print_success "User lingering enabled (service will start at boot)"
    else
        print_warning "Failed to enable user lingering"
        print_warning "Service may not start automatically at boot"
        print_status "You can enable it manually with: sudo loginctl enable-linger $USER"
    fi
    
    print_success "Service configured for automatic startup"
}

# Start the service with status monitoring
start_service() {
    print_status "Starting the service..."
    
    # Stop the service first if it's already running
    if systemctl --user is-active "$SERVICE_NAME.service" >/dev/null 2>&1; then
        print_status "Stopping existing service..."
        systemctl --user stop "$SERVICE_NAME.service" || true
        sleep 1
    fi
    
    # Start the service
    if systemctl --user start "$SERVICE_NAME.service"; then
        print_success "Service start command issued"
        
        # Wait for service to initialize
        print_status "Waiting for service to initialize..."
        sleep 3
        
        # Check if service is actually running
        if systemctl --user is-active "$SERVICE_NAME.service" >/dev/null 2>&1; then
            print_success "Service is running successfully"
        else
            print_warning "Service may have failed to start properly"
        fi
        
        # Show service status
        echo
        print_status "Current service status:"
        systemctl --user status "$SERVICE_NAME.service" --no-pager -l || true
        
    else
        print_error "Failed to start service"
        print_status "Checking service status for error details..."
        echo
        systemctl --user status "$SERVICE_NAME.service" --no-pager -l || true
        echo
        print_status "Check logs with: journalctl --user -u $SERVICE_NAME.service -f"
        return 1
    fi
}

# Test service configuration
test_service() {
    print_status "Testing service configuration..."
    
    if [[ ! -f "$SERVICE_FILE" ]]; then
        SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE_NAME.service"
    fi
    
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_error "Service file not found"
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
    local script_path="$INSTALL_DIR/$SCRIPT_NAME"
    if [[ -x "$script_path" ]]; then
        print_success "Main script is installed and executable"
    else
        print_error "Main script not found or not executable at $script_path"
        return 1
    fi
    
    # Test script syntax if it's a shell script
    if head -n1 "$script_path" | grep -q "bash\|sh"; then
        if bash -n "$script_path" 2>/dev/null; then
            print_success "Script syntax is valid"
        else
            print_warning "Script may have syntax issues"
        fi
    fi
    
    return 0
}

# Show comprehensive usage instructions
show_usage() {
    echo
    print_header "╔════════════════════════════════════════════════════════════════════════════════════════╗"
    print_header "║                              Installation Completed!                                   ║"
    print_header "╚════════════════════════════════════════════════════════════════════════════════════════╝"
    echo
    
    echo -e "${GREEN}The Spotify Ad Muter has been successfully installed and configured.${NC}"
    echo
    
    echo -e "${CYAN}Automatic Operation:${NC}"
    echo "  • The service starts automatically when you log in"
    echo "  • It waits for Spotify to launch and monitors for advertisements"
    echo "  • Audio is muted during ads and restored when music resumes"
    echo "  • Monitoring continues even if Spotify is restarted"
    echo
    
    echo -e "${CYAN}Manual Service Control:${NC}"
    echo "  Start service:     systemctl --user start $SERVICE_NAME"
    echo "  Stop service:      systemctl --user stop $SERVICE_NAME"
    echo "  Restart service:   systemctl --user restart $SERVICE_NAME"
    echo "  Service status:    systemctl --user status $SERVICE_NAME"
    echo "  View logs:         journalctl --user -u $SERVICE_NAME -f"
    echo "  Enable at boot:    systemctl --user enable $SERVICE_NAME"
    echo "  Disable at boot:   systemctl --user disable $SERVICE_NAME"
    echo
    
    echo -e "${CYAN}Direct Script Usage:"
    echo "  Run manually:      $INSTALL_DIR/$SCRIPT_NAME"
    echo "  Show help:         $INSTALL_DIR/$SCRIPT_NAME --help"
    echo "  Test mode:         $INSTALL_DIR/$SCRIPT_NAME --test"
    echo
    
    echo -e "${CYAN}Troubleshooting:"
    echo "  • Use 'systemctl --user' commands (NOT 'sudo systemctl')"
    echo "  • If the service fails to start, check: journalctl --user -u $SERVICE_NAME"
    echo "  • For permission issues, try: $0 --fix"
    echo "  • To reinstall completely: $0 --uninstall && $0"
    echo
    
    echo -e "${CYAN}Files Created:"
    echo "  • Script: $INSTALL_DIR/$SCRIPT_NAME"
    echo "  • Service: $HOME/.config/systemd/user/$SERVICE_NAME.service"
    echo
    
    print_status "Tip: The service will automatically detect when Spotify starts or stops."
}



# Fix existing installation
fix_service() {
    print_status "Fixing existing service configuration..."
    
    # Stop the service if it's running
    if systemctl --user is-active "$SERVICE_NAME.service" >/dev/null 2>&1; then
        print_status "Stopping service..."
        systemctl --user stop "$SERVICE_NAME.service" 2>/dev/null || true
    fi
    
    # Reset failed state if needed
    if systemctl --user is-failed "$SERVICE_NAME.service" >/dev/null 2>&1; then
        print_status "Resetting failed service state..."
        systemctl --user reset-failed "$SERVICE_NAME.service" 2>/dev/null || true
    fi
    
    # Recreate the service file
    create_user_service
    
    # Reload and enable
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

# Show system information for debugging
show_debug_info() {
    print_header "System Information for Debugging"
    echo "=================================="
    
    echo "Distribution: $(detect_distro)"
    echo "Bash version: $BASH_VERSION"
    echo "User: $USER (UID: $(id -u))"
    echo "Home: $HOME"
    echo "XDG_RUNTIME_DIR: ${XDG_RUNTIME_DIR:-not set}"
    echo "DISPLAY: ${DISPLAY:-not set}"
    
    echo
    echo "Service status:"
    systemctl --user status "$SERVICE_NAME.service" --no-pager -l 2>/dev/null || echo "Service not found"
    
    echo
    echo "Dependencies:"
    for cmd in playerctl pactl amixer curl systemctl; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "  ✓ $cmd: $(command -v "$cmd")"
        else
            echo "  ✗ $cmd: not found"
        fi
    done
    
    echo
    echo "Files:"
    local script_file="$INSTALL_DIR/$SCRIPT_NAME"
    local service_file="$HOME/.config/systemd/user/$SERVICE_NAME.service"
    
    echo "  Script: $script_file"
    if [[ -f "$script_file" ]]; then
        echo "    ✓ Exists, size: $(stat -f%z "$script_file" 2>/dev/null || stat -c%s "$script_file" 2>/dev/null) bytes"
        echo "    ✓ Permissions: $(ls -la "$script_file" | cut -d' ' -f1)"
    else
        echo "    ✗ Not found"
    fi
    
    echo "  Service: $service_file"
    if [[ -f "$service_file" ]]; then
        echo "    ✓ Exists"
    else
        echo "    ✗ Not found"
    fi
}

# Main installation function
main() {
    print_header "╔════════════════════════════════════════════════════════════════════════════════════════╗"
    print_header "║                           Spotify Ad Muter - Installation Script                       ║"
    print_header "║                                      Version $SCRIPT_VERSION                                       ║"
    print_header "╚════════════════════════════════════════════════════════════════════════════════════════╝"
    echo
    
    check_bash_version
    check_root
    check_sudo
    check_dependencies
    
    # Download the script
    print_status "Starting installation process..."
    local temp_script
    if ! temp_script="$(download_script)"; then
        print_error "Failed to download script"
        exit 1
    fi
    
    # Install components
    install_script "$temp_script" || exit 1
    create_user_service || exit 1
    enable_service || exit 1
    
    # Test the service before starting
    if test_service; then
        start_service || exit 1
    else
        print_error "Service configuration test failed"
        exit 1
    fi
    
    show_usage
    
    echo
    print_success "Installation completed successfully!"
    print_status "The service should now be running. Check with: systemctl --user status $SERVICE_NAME"
}

# Enhanced command line argument handling
case "${1:-}" in
    --install|"")
        main
        ;;
    --uninstall|-u)
        print_status "The uninstall function has been moved to a separate script."
        print_status "Please use ./uninstall.sh to remove the installation."
        exit 0
        ;;
    --fix|-f)
        fix_service
        ;;
    --test|-t)
        test_service
        exit $?
        ;;
    --debug)
        show_debug_info
        ;;
    --version|-v)
        echo "Spotify Ad Muter Installation Script v$SCRIPT_VERSION"
        exit 0
        ;;
    --help|-h)
        cat << 'EOF'
Spotify Ad Muter Installation Script

USAGE:
    install.sh [COMMAND] [OPTIONS]

COMMANDS:
    (no command)     Install the Spotify ad muter (default)
    --install        Same as default
    --uninstall, -u  Redirects to uninstall.sh
    --fix, -f        Fix existing service configuration
    --test, -t       Test service configuration
    --debug          Show system information for debugging
    --version, -v    Show script version
    --help, -h       Show this help

ENVIRONMENT VARIABLES:
    DEBUG=1          Enable debug output

DESCRIPTION:
    This script automates the installation of the Spotify Ad Muter, which
    automatically detects and mutes Spotify advertisements. The script will:

    1. Check system compatibility and dependencies
    2. Download the latest ad muter script from GitHub  
    3. Install it system-wide in /usr/local/bin
    4. Create and configure a systemd user service
    5. Enable automatic startup when you log in

SYSTEM REQUIREMENTS:
    - Linux with systemd
    - Bash 4.0 or later
    - sudo access
    - Internet connection
    - Dependencies: playerctl, pulseaudio-utils/alsa-utils, curl

USAGE NOTES:
    - Always use 'systemctl --user' commands (not 'sudo systemctl')
    - The service runs as your user, not as root
    - If installation fails, try: ./install.sh --fix
    - Check service logs with: journalctl --user -u no-spotify-ads -f
    - To uninstall, use ./uninstall.sh

EXAMPLES:
    ./install.sh                    # Install normally
    ./uninstall.sh                  # Remove installation
    ./install.sh --fix              # Fix broken service
    DEBUG=1 ./install.sh --debug    # Show debug information

For more information, visit:
https://github.com/basbassi-houssam/no_spotify_ads_linux
EOF
        exit 0
        ;;
    *)
        print_error "Unknown option: $1"
        print_error "Use --help for usage information"
        exit 1
        ;;
esac
