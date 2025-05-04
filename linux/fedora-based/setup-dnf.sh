#!/bin/bash
set -euo pipefail

log() {
    echo -e "\n🔹 $1"
}

warn() {
    echo -e "\n⚠️ $1"
}

run_safe() {
    "$@" || warn "Failed: $*"
}

# 1. Speed up DNF
speed_up_dnf() {
    log "Optimizing DNF for faster updates..."
    CONFIG_FILE="/etc/dnf/dnf.conf"
    if ! grep -q "fastestmirror=True" $CONFIG_FILE 2>/dev/null; then
        sudo tee -a $CONFIG_FILE > /dev/null <<EOF
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
EOF
    else
        log "DNF already optimized."
    fi
}

# 2. Enable RPM Fusion
enable_rpmfusion() {
    log "Enabling RPM Fusion (Free & Non-Free)..."
    if ! rpm -q rpmfusion-free-release &>/dev/null; then
        run_safe sudo dnf install -y \
            https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    fi
    if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
        run_safe sudo dnf install -y \
            https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi
}

# 3. Enable Flathub
enable_flathub() {
    log "Enabling Flathub for Flatpak..."
    if ! flatpak remotes | grep -q flathub; then
        run_safe sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        log "Flathub already enabled."
    fi
}

# 4. Install multimedia codecs
install_multimedia_codecs() {
    log "Installing Multimedia codecs..."
    run_safe sudo dnf group install -y multimedia
    if rpm -q ffmpeg-free &>/dev/null; then
        run_safe sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
    fi
    run_safe sudo dnf upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    run_safe sudo dnf group install -y sound-and-video
}

# 5. Hardware Video Acceleration
install_hw_acceleration() {
    log "Installing Hardware Video Acceleration..."
    run_safe sudo dnf install -y ffmpeg-libs libva libva-utils
}

# 6. OpenH264 for Firefox
install_openh264() {
    log "Installing OpenH264 for Firefox..."
    if ! rpm -q mozilla-openh264 &>/dev/null; then
        run_safe sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
    fi
    run_safe sudo dnf config-manager --set-enabled fedora-cisco-openh264
    echo "🔔 Please enable OpenH264 in Firefox Preferences manually."
}

# 7. Reset Firefox start page
reset_firefox_start_page() {
    log "Resetting Firefox start page to default..."
    FILE="/usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js"
    if [ -f "$FILE" ]; then
        run_safe sudo rm -f "$FILE"
    else
        log "Firefox default override already removed."
    fi
}

main() {
    speed_up_dnf
    enable_rpmfusion
    enable_flathub
    install_multimedia_codecs
    install_hw_acceleration
    install_openh264
    reset_firefox_start_page
    echo -e "\n✅ All done!"
}

main
