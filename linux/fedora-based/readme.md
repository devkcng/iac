# Fedora 42 Post-Install Guide

A comprehensive guide to optimize and enhance your Fedora 42 experience.

---

## Table of Contents

1. [Increase DNF Update Speed](#increase-dnf-update-speed)
2. [Enable RPM Fusion & Terra Repositories](#enable-rpm-fusion--terra-repositories)
3. [System Update](#system-update)
4. [Firmware Updates](#firmware-updates)
5. [Flatpak Setup](#flatpak-setup)
6. [AppImage Support](#appimage-support)
7. [NVIDIA Drivers](#nvidia-drivers)
8. [Media Codecs](#media-codecs)
9. [Hardware Video Acceleration](#hardware-video-acceleration)
10. [Set Hostname](#set-hostname)
11. [Default Firefox Start Page](#default-firefox-start-page)
12. [Custom DNS Servers](#custom-dns-servers)
13. [Set UTC Time](#set-utc-time)
14. [Install Fcitx5 for Vietnamese Input](#install-fcitx5-for-vietnamese-input)
15. [System Optimizations](#system-optimizations)
16. [Gnome Extensions](#gnome-extensions)
17. [Optional Apps](#optional-apps)
18. [Customize Konsole](#customize-konsole-zsh-oh-my-zsh-starship-and-eza)
19. [Setup Development Environment (Optional)](#setup-development-environment-optional)

---

## Increase DNF Update Speed

Edit `/etc/dnf/dnf.conf` and add:

```ini
fastestmirror=True
max_parallel_downloads=10
skip_if_unavailable=True
```

---

## Enable RPM Fusion & Terra Repositories

### RPM Fusion

Enable free and non-free repositories:

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### Terra

Add the Terra repository:

```bash
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf group upgrade core
sudo dnf4 group install core
```

---

## System Update

Update your system:

```bash
sudo dnf -y update
```

Reboot after updates.

---

## Firmware Updates

Update firmware via `fwupd`:

```bash
sudo fwupdmgr refresh --force
sudo fwupdmgr get-devices
sudo fwupdmgr get-updates
sudo fwupdmgr update
```

---

## Flatpak Setup

Enable Flathub:

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

---

## AppImage Support

Install `fuse` for AppImage support:

```bash
sudo dnf install fuse
```

Optional: Install [Gearlever](https://flathub.org/apps/it.mijorus.gearlever):

```bash
flatpak install it.mijorus.gearlever
```

---

## NVIDIA Drivers

### For Supported GPUs

1. Update kernel and reboot:

    ```bash
    sudo dnf update
    ```

2. Install NVIDIA drivers:

    ```bash
    sudo dnf install akmod-nvidia
    ```

3. Optional: Install CUDA support:

    ```bash
    sudo dnf install xorg-x11-drv-nvidia-cuda
    ```

4. Verify kernel module:

    ```bash
    modinfo -F version nvidia
    ```

5. Reboot.

---

## Media Codecs

Install multimedia codecs:

```bash
sudo dnf4 group install multimedia
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
sudo dnf upgrade @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf group install -y sound-and-video
```

---

## Hardware Video Acceleration

### Install Required Libraries

```bash
sudo dnf install ffmpeg-libs libva libva-utils
```

#### Intel

```bash
sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
sudo dnf install libva-intel-driver
```

#### AMD

```bash
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
```

#### OpenH264 for Firefox

```bash
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
```

---

## Set Hostname

```bash
hostnamectl set-hostname YOUR_HOSTNAME
```

---

## Default Firefox Start Page

Restore default start page:

```bash
sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js
```

---

## Custom DNS Servers

Configure DNS over TLS:

```bash
sudo mkdir -p '/etc/systemd/resolved.conf.d'
sudo nano '/etc/systemd/resolved.conf.d/99-dns-over-tls.conf'
```

Add:

```ini
[Resolve]
DNS=1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com
DNSOverTLS=yes
```

---

## Set UTC Time

For dual-boot systems:

```bash
sudo timedatectl set-local-rtc 0
```

---

## Install Fcitx5 for Vietnamese Input

1. Install required packages:

    ```bash
    sudo dnf install fcitx5 fcitx5-unikey fcitx5-qt fcitx5-gtk
    ```

2. Configure environment variables:

    ```bash
    nano ~/.pam_environment
    ```

    Add:

    ```ini
    GTK_IM_MODULE=fcitx
    QT_IM_MODULE=fcitx
    XMODIFIERS=@im=fcitx
    INPUT_METHOD=fcitx
    ```

3. Autostart Fcitx5:

    ```bash
    mkdir -p ~/.config/autostart
    cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
    ```

4. Configure input methods:

    ```bash
    fcitx5-configtool
    ```

5. Reboot.

---

## System Optimizations

### Disable Mitigations

```bash
sudo grubby --update-kernel=ALL --args="mitigations=off"
```

### Enable NVIDIA Modeset (if using NVIDIA)

```bash
sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"
```

### Disable NetworkManager Wait Service

```bash
sudo systemctl disable NetworkManager-wait-online.service
```

### Disable Gnome Software Autostart

```bash
sudo rm /etc/xdg/autostart/org.gnome.Software.desktop
```

---

## Gnome Extensions

Install recommended extensions:

- **Pop Shell**: `sudo dnf install -y gnome-shell-extension-pop-shell xprop`
- **GSconnect**: `sudo dnf install nautilus-python`
- [Gesture Improvements](https://extensions.gnome.org/extension/4245/gesture-improvements/)
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)

---

## Optional Apps

Install additional tools:

```bash
sudo dnf install -y unzip p7zip p7zip-plugins unrar
```

Recommended apps:

- Discord
- yt-dlp
- OBS Studio
- Telegram
- VLC

Install them via Flatpak or RPM.

---

## Customize Konsole (ZSH, Oh My Zsh, Starship and eza)

Before starting, make sure you have installed a nerd font in your system.
You can download a nerd font from [Nerd font website](https://www.nerdfonts.com/).
I use [Fira Code Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode).

After installing the font, you can set it as default font in Konsole.
You can set the font in Konsole by going to `Settings` > `Edit Current Profile` > `Appearance` > `Edit Font`.
Now, you can set the font to `Fira Code Nerd Font`.

1. Install ZSH:

    ```bash
    sudo dnf install zsh
    ```

2. Set ZSH as default shell:

    ```bash
    chsh -s $(which zsh)
    ```

3. Install Oh My Zsh:

    ```bash
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```

4. Install and configure Starship:

    ```bash
    curl -sS https://starship.rs/install.sh | sh
    ```

    1. Configure Starship:
        Edit `~/.zshrc` and add:

        ```bash
        eval "$(starship init zsh)"
        ```

    2. Optional: Install a Starship theme.

        Starship supports various themes, including Powerlevel10k, Agnoster, and others.
        You can find a list of themes [here](https://starship.rs/themes/).
        You can choose any theme you like. For this guide, I will use the [Catppuccin](https://github.com/catppuccin/starship) theme.

        By default, Starship uses the `~/.config/starship.toml` file for configuration.

        But I will do it differently. I will change the default path of Starship configuration file by add this line to `~/.zshrc`:

        ```ini
        STARSHIP_CONFIG=~/.config/starship/starship.toml
        ```

        This will change the default path of Starship configuration file to `~/.config/starship/starship.toml`.
        Now, I will clone the Catppuccin theme repository and copy all files inside that repository to `~/.config/starship` folder.

        ```bash
        git clone https://github.com/catppuccin/starship ~/.config/starship
        ```

        Now, you will have Starship configuration with Catppuccin theme in `~/.config/starship` folder.

    3. Restart your terminal or run `source ~/.zshrc` to apply changes.

5. Install additional ZSH plugins:
    - **zsh-autosuggestions**: Provides suggestions based on command history.
    - **zsh-syntax-highlighting**: Highlights commands as you type.
    - **zsh-completions**: Additional completion definitions for ZSH.
    - **zsh-history-substring-search**: Search through command history.

    Install them using:

    ```bash
    # Install plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

    ```

    Add the plugins to your `~/.zshrc` file:

    ```bash
    plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search)
    ```

    Restart your terminal or run `source ~/.zshrc` to apply changes.
    Now, you will have ZSH with Oh My Zsh and Starship installed and configured.

6. Install `eza` for better `ls` command:

    ```bash
    sudo dnf install eza
    ```

    Add to `~/.zshrc`:

    ```ini
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --group-directories-first'
    alias la='eza -lah --icons --group-directories-first'
    alias lt='eza -T --icons --group-directories-first --level=2'
    ```

---

## Setup Development Environment (Optional)

1. Install the Development Tools group in Fedora. This will provide a set of essential tools, including compilers, debuggers, and other utilities:

    ```bash
    sudo dnf group install development-tools
    ```

2. Install a code editor. For this guide, we will use Visual Studio Code. You can install it from the official repository or download the RPM package from the [official website](https://code.visualstudio.com/).

    To install Visual Studio Code from the official repository:

    - Import the Microsoft GPG key:

        ```bash
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        ```

    - Add the Visual Studio Code repository:

        ```bash
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
        ```

    - Update the package cache and install Visual Studio Code:

        ```bash
        sudo dnf install code # or code-insiders
        ```

3. Install Docker:

   **Uninstall Old Versions**

    Remove any conflicting Docker packages:

    ```bash
    sudo dnf remove docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-selinux \
                    docker-engine-selinux \
                    docker-engine
    ```

    > **Note**: Existing images, containers, volumes, and networks in `/var/lib/docker/` are not removed.

   **Install Docker Engine**

    1. Set up the repository:

        ```bash
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        ```

    2. Install Docker:

        ```bash
        sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```

        Verify the GPG key fingerprint: `060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35`.

    3. Start Docker:

        ```bash
        sudo systemctl enable --now docker
        ```

    4. Test the installation:

        ```bash
        sudo docker run hello-world
        ```

4. Install Node.js via NVM:

    1. Install NVM:

        ```bash
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        ```

    2. Load NVM and add to your shell profile:

        ```bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        ```

        Add the above lines to your `~/.zshrc` file.
        Then, run:

        ```bash
        source ~/.zshrc
        ```

        to load NVM.

    3. Install Node.js:

        ```bash
        nvm install --lts
        ```

    4. Verify installation:

        ```bash
        node -v
        npm -v
        ```

    5. Optional: Set default Node.js version:

        ```bash
        nvm alias default node
        ```

## Conclusion

Enjoy your optimized Fedora 42 experience!

This guide is a work in progress. Feel free to contribute or suggest improvements.

Special thanks to this [Fedora Install Guide](https://github.com/devangshekhawat/Fedora-42-Post-Install-Guide) for inspiration and some content.
