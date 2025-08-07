#!/bin/bash

# Spotify Ad Muter Uninstallation Script
# This script removes the NoSpotifyAds script and service
# Version: 2.0

set -euo pipefail
IFS=$'\n\t'

# Configuration
readonly SCRIPT_NAME="no-spotify-ads"
readonly INSTALL_DIR="/usr/local/bin"
readonly SERVICE_NAME="no-spotify-ads"
readonly SCRIPT_VERSION="2.0"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

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

# Check if user has sudo access
check_sudo() {
    print_status "Checking sudo access..."
    
    if ! command -v sudo >/dev/null 2>&1; then
        print_error "sudo command not found. Please install sudo or run as root."
        exit 1
    fi
    
    if ! sudo -n true 2>/dev/null; then
        print_status "This script requires sudo access for system file removal."
        print_status "You may be prompted for your password."
        
        # Test sudo with a simple command
        if ! sudo true; then
            print_error "Cannot obtain sudo privileges"
            exit 1
        fi
    fi
    
    print_success "Sudo access confirmed"
}

# Comprehensive uninstall function
uninstall() {
    print_header "╔════════════════════════════════════════════════════════════════════════════════════════╗"
    print_header "║                           Spotify Ad Muter - Uninstallation                            ║"
    print_header "║                                      Version $SCRIPT_VERSION                                       ║"
    print_header "╚════════════════════════════════════════════════════════════════════════════════════════╝"
    echo
    
    print_status "Uninstalling Spotify Ad Muter..."
    
    local removed_files=0
    local errors=0
    
    # Stop and disable service
    if systemctl --user is-enabled "$SERVICE_NAME.service" >/dev/null 2>&1; then
        print_status "Stopping and disabling service..."
        if systemctl --user stop "$SERVICE_NAME.service" 2>/dev/null; then
            print_success "Service stopped"
        else
            print_warning "Failed to stop service (may not be running)"
        fi
        
        if systemctl --user disable "$SERVICE_NAME.service" 2>/dev/null; then
            print_success "Service disabled"
            ((removed_files++))
        else
            print_warning "Failed to disable service"
            ((errors++))
        fi
    else
        print_status "Service not enabled or doesn't exist"
    fi
    
    # Remove service file
    local service_file="$HOME/.config/systemd/user/$SERVICE_NAME.service"
    if [[ -f "$service_file" ]]; then
        if rm -f "$service_file"; then
            print_success "Service file removed"
            ((removed_files++))
            
            # Reload systemd daemon
            if systemctl --user daemon-reload 2>/dev/null; then
                print_success "Systemd user daemon reloaded"
            else
                print_warning "Failed to reload systemd daemon"
            fi
        else
            print_error "Failed to remove service file"
            ((errors++))
        fi
    else
        print_status "Service file not found"
    fi
    
    # Remove script
    local script_file="$INSTALL_DIR/$SCRIPT_NAME"
    if [[ -f "$script_file" ]]; then
        # Create one final backup before removal (optional)
        local backup="${script_file}.removed.$(date +%Y%m%d_%H%M%S)"
        if sudo cp "$script_file" "$backup" 2>/dev/null; then
            print_status "Final backup created at $backup"
        else
            print_debug "Failed to create backup (continuing anyway)"
        fi
        
        if sudo rm -f "$script_file" 2>/dev/null; then
            print_success "Script removed from $script_file"
            ((removed_files++))
        else
            print_error "Failed to remove script from $script_file"
            ((errors++))
        fi
    else
        print_status "Script file not found"
    fi
    
    # Remove backup files (optional)
    local backups
    backups="$(sudo find "$INSTALL_DIR" -name "${SCRIPT_NAME}.backup.*" 2>/dev/null)" || backups=""
    
    if [[ -n "$backups" ]]; then
        echo
        print_status "Found backup files:"
        echo "$backups"
        read -p "Remove backup files as well? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$backups" | while IFS= read -r backup; do
                if [[ -f "$backup" ]] && sudo rm -f "$backup" 2>/dev/null; then
                    print_status "Removed backup: $backup"
                else
                    print_warning "Failed to remove backup: $backup"
                fi
            done
        fi
    fi
    
    # Optionally disable user lingering
    if sudo loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
        echo
        read -p "Disable user lingering (auto-start services at boot)? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if sudo loginctl disable-linger "$USER" 2>/dev/null; then
                print_success "User lingering disabled"
            else
                print_warning "Failed to disable user lingering"
            fi
        fi
    fi
    
    echo
    if [[ $removed_files -gt 0 ]]; then
        if [[ $errors -eq 0 ]]; then
            print_success "Uninstallation completed successfully!"
        else
            print_warning "Uninstallation completed with $errors error(s)"
        fi
        print_status "$removed_files file(s) removed"
    else
        print_warning "No files found to remove (may already be uninstalled)"
    fi
    
    echo
    print_status "Spotify Ad Muter has been uninstalled from your system."
    
    if [[ $errors -gt 0 ]]; then
        echo
        print_status "If you encountered errors, you may need to manually remove:"
        print_status "  - Script: $INSTALL_DIR/$SCRIPT_NAME"
        print_status "  - Service: $HOME/.config/systemd/user/$SERVICE_NAME.service"
        print_status "  - Backup files: $INSTALL_DIR/$SCRIPT_NAME.backup.*"
    fi
}

# Enhanced command line argument handling
case "${1:-}" in
    ""|--uninstall|-u)
        check_sudo
        uninstall
        ;;
    --version|-v)
        echo "Spotify Ad Muter Uninstallation Script v$SCRIPT_VERSION"
        exit 0
        ;;
    --help|-h)
        cat << 'EOF'
Spotify Ad Muter Uninstallation Script

USAGE:
    uninstall.sh [OPTIONS]

OPTIONS:
    (no option)      Uninstall the Spotify ad muter (default)
    --uninstall, -u  Same as default
    --version, -v    Show script version
    --help, -h       Show this help

ENVIRONMENT VARIABLES:
    DEBUG=1          Enable debug output

DESCRIPTION:
    This script removes the Spotify Ad Muter installation, including:
    
    1. Stopping and disabling the systemd user service
    2. Removing the service file
    3. Removing the main script from /usr/local/bin
    4. Optionally removing backup files
    5. Optionally disabling user lingering

WHAT IT REMOVES:
    • Script: /usr/local/bin/no-spotify-ads
    • Service: ~/.config/systemd/user/no-spotify-ads.service
    • Backup files: /usr/local/bin/no-spotify-ads.backup.* (optional)
    • User lingering setting (optional)

EXAMPLES:
    ./uninstall.sh          # Uninstall normally
    ./uninstall.sh --help   # Show this help
    DEBUG=1 ./uninstall.sh  # Show debug information

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
