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

# 1. Update & upgrade system
run_step "Updating system packages" sudo apt update
run_step "Upgrading system packages" sudo apt upgrade -y

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

# 8. Install Zsh
run_step "Installing Zsh" sudo apt install -y zsh

# 9. Change default shell to Zsh (interactive)
run_step "Setting Zsh as default shell" chsh -s "$(which zsh)"

# 10. Install Oh My Zsh
run_step "Installing Oh My Zsh" bash -c '
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || echo "⚠️ Oh My Zsh install might require manual setup." >> "$LOG_FILE"
else
  echo "✅ Oh My Zsh is already installed"
fi
'

# 11. Zsh Plugins
run_step "Installing Zsh syntax highlighting" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
  echo "✅ Zsh syntax highlighting is already installed"
fi
'

run_step "Installing Zsh autosuggestions" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
  echo "✅ Zsh autosuggestions is already installed"
fi
'

run_step "Installing Zinit plugin manager" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zinit" ]; then
  git clone https://github.com/zdharma-continuum/zinit.git ~/.oh-my-zsh/custom/plugins/zinit
else
  echo "✅ Zinit plugin manager is already installed"
fi
'

# 12. Powerlevel10k theme
run_step "Installing Powerlevel10k theme" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
else
  echo "✅ Powerlevel10k theme is already installed"
fi
'

# 13. Modify .zshrc
run_step "Updating .zshrc config" bash -c '
if ! grep -q "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" ~/.zshrc; then
  sed -i "s|ZSH_THEME=.*|ZSH_THEME=\"powerlevel10k/powerlevel10k\"|" ~/.zshrc
  echo -e "\nplugins=(git zsh-syntax-highlighting zsh-autosuggestions zinit)" >> ~/.zshrc
else
  echo "✅ .zshrc is already updated"
fi
'

# 14. Install Flatpak apps (Telegram, VLC)
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
