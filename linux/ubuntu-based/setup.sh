#!/bin/bash

LOG_FILE="$(dirname "$0")/setup_errors.log"
touch "$LOG_FILE"

echo "🔧 Starting system setup..."
echo "🪵 Errors will be logged to: $LOG_FILE"
echo "----------------------------------------"

# Allow script to continue even if a command fails
set +e

run_step() {
  DESC="$1"
  shift
  echo -e "\n👉 $DESC..."
  "$@"
  local STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "❌ $DESC failed with status $STATUS" | tee -a "$LOG_FILE"
  fi
}

# Update & upgrade system
run_step "Updating system packages" sudo apt update -y
run_step "Upgrading system packages" sudo apt upgrade -y

# 1. Install Tilix and make it default terminal:
run_step "Installing Tilix" sudo apt-get install tilix

# Fix Tilix VTE support
run_step "Fixing Tilix VTE" bash -c '
if [ -f /etc/profile.d/vte-2.91.sh ]; then
  sudo ln -sf /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
  sudo chmod +x /etc/profile.d/vte.sh

  if ! grep -q "vte.sh" ~/.bashrc; then
    echo -e "\n# Enable VTE for Tilix" >> ~/.bashrc
    echo "if [ \$TILIX_ID ] || [ \$VTE_VERSION ]; then" >> ~/.bashrc
    echo "    source /etc/profile.d/vte.sh" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
  else
    echo "✅ VTE fix already in .bashrc"
  fi
else
  echo "⚠️ vte-2.91.sh not found. Skipping VTE fix."
fi
'

# Check if Tilix is already the default terminal
DEFAULT_TERM=$(readlink -f /etc/alternatives/x-terminal-emulator)
if [[ "$DEFAULT_TERM" != *tilix* ]]; then
  run_step "Setting Tilix as default terminal" sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix
else
  echo "✅ Tilix is already set as the default terminal emulator"
fi

# Relaunch the script in Tilix if not already running inside it
if [ -z "$TILIX_ID" ]; then
  echo -e "\n🧪 Not running inside Tilix. Relaunching setup inside Tilix..."

  TILIX_PATH=$(command -v tilix)
  if [ -n "$TILIX_PATH" ]; then
    "$TILIX_PATH" -e bash -c "bash '$0'"
    echo "🛑 Exiting current terminal. Setup continues in Tilix..."
    exit 0
  else
    echo "❌ Tilix not found in PATH. Please install manually."
    exit 1
  fi
else
  echo "✅ Already running inside Tilix. Continuing setup..."
fi

# 2. Install essential packages
run_step "Installing essential packages" sudo apt install -y \
    git curl wget vim tmux htop build-essential unzip \
    software-properties-common python3 python3-pip neofetch \
    net-tools gnupg ca-certificates lsb-release

# 3. Setup Git
run_step "Setting up Git username" git config --global user.name "Cuong Kim"
run_step "Setting up Git email" git config --global user.email "kimmanhcuong230304@gmail.com"

# 4. Install Docker
run_step "Installing Docker" bash -c '
if ! command -v docker &> /dev/null; then
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG $USER docker
else
  echo "✅ Docker is already installed"
fi
'


# 5. Install Node.js using nvm
run_step "Installing Node.js via nvm (Node Version Manager)" bash -c '
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
else
  echo "✅ NVM is already installed"
fi
'

# Add nvm to .zshrc
run_step "Adding nvm config to .zshrc" bash -c '
if ! grep -q "nvm.sh" ~/.zshrc; then
  echo -e "\n# nvm config" >> ~/.zshrc
  echo "export NVM_DIR=\"\$HOME/.nvm\"" >> ~/.zshrc
  echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >> ~/.zshrc
fi
'

# 6. Install VS Code
run_step "Installing VS Code" bash -c '
if ! command -v code &> /dev/null; then
  sudo apt-get install -y wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
  https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  rm -f packages.microsoft.gpg
  sudo apt install -y apt-transport-https
  sudo apt update
  sudo apt install -y code
else
  echo "✅ VS Code is already installed"
fi
'

# 7. Install IBus Bamboo
run_step "Installing IBus Bamboo" bash -c '
if ! dpkg -l | grep -q "ibus-bamboo"; then
  sudo add-apt-repository -y ppa:bamboo-engine/ibus-bamboo
  sudo apt update
  sudo apt install -y ibus ibus-bamboo

  # Set IBus as the default input method
  im-config -n ibus

  # Ensure ibus-daemon starts on login
  echo -e "\n# IBus setup" >> ~/.xprofile
  echo "export GTK_IM_MODULE=ibus" >> ~/.xprofile
  echo "export QT_IM_MODULE=ibus" >> ~/.xprofile
  echo "export XMODIFIERS=@im=ibus" >> ~/.xprofile
  echo "ibus-daemon -drx" >> ~/.xprofile

  # Start IBus daemon for current session
  ibus-daemon -drx || echo "⚠️ Could not start ibus-daemon, please reboot or log out/in." >> "$LOG_FILE"
else
  echo "✅ IBus Bamboo is already installed"
fi
'

# 8. Install Flatpak apps (Telegram, VLC)
run_step "Installing Flatpak" sudo apt install -y flatpak
run_step "Adding Flathub repository" bash -c '
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
'

run_step "Installing Telegram (Flatpak)" bash -c '
if ! flatpak list | grep -q "org.telegram.desktop"; then
  flatpak install -y flathub org.telegram.desktop
else
  echo "✅ Telegram is already installed"
fi
'

run_step "Installing VLC (Flatpak)" bash -c '
if ! flatpak list | grep -q "org.videolan.VLC"; then
  flatpak install -y flathub org.videolan.VLC
else
  echo "✅ VLC is already installed"
fi
'

echo -e "\n✅ Setup completed!"
echo "📄 Errors (if any) are logged in: $LOG_FILE"
echo "🚀 Please reboot or open a new terminal to start using Zsh!"
