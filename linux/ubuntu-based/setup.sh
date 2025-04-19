#!/bin/bash

set -e

echo "🔧 Starting system setup..."

# -----------------------------
# 1. Update & upgrade system
# -----------------------------
echo "📦 Updating packages..."
sudo apt update && sudo apt upgrade -y

# -----------------------------
# 2. Install essential packages
# -----------------------------
echo "📥 Installing essential packages..."
sudo apt install -y \
    git \
    curl \
    wget \
    vim \
    tmux \
    htop \
    build-essential \
    unzip \
    software-properties-common \
    python3 \
    python3-pip \
    neofetch \
    net-tools \
    gnupg \
    ca-certificates \
    lsb-release \
    snapd

# -----------------------------
# 3. Setup Git
# -----------------------------
echo "🛠️ Setting up Git config..."
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# -----------------------------
# 4. Install Docker (official way)
# -----------------------------
echo "🐳 Installing Docker (official method)..."

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker service and add current user to docker group
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# -----------------------------
# 5. Install Node.js (optional)
# -----------------------------
echo "🟢 Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# -----------------------------
# 6. Install VS Code (Snap)
# -----------------------------
echo "🖥️ Installing VS Code via Snap..."
sudo snap install code --classic

# -----------------------------
# 7. Install Vietnamese IBus Bamboo
# -----------------------------
echo "🇻🇳 Installing IBus Bamboo for Vietnamese input..."
sudo add-apt-repository -y ppa:bamboo-engine/ibus-bamboo
sudo apt update
sudo apt install -y ibus-bamboo
ibus restart

echo "👉 Open 'Language Support', set Keyboard Input Method System to 'IBus', then reboot to activate Bamboo input."

# -----------------------------
# 8. Install Zsh (last step)
# -----------------------------
echo "💡 Installing Zsh..."
sudo apt install -y zsh

# Set Zsh as the default shell
chsh -s $(which zsh)

# -----------------------------
# 9. Install Oh My Zsh and plugins
# -----------------------------
echo "🔧 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "🔌 Installing Zsh plugins..."
# Install plugins using `zsh-users` plugin manager
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/zinit.git ~/.oh-my-zsh/custom/plugins/zinit

# -----------------------------
# 10. Install Powerlevel10k theme
# -----------------------------
echo "🎨 Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# -----------------------------
# 11. Update .zshrc for Powerlevel10k and plugins
# -----------------------------
echo "📝 Updating .zshrc with Powerlevel10k theme and plugins..."
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k/powerlevel10k"/g' ~/.zshrc
echo 'plugins=(git zsh-syntax-highlighting zsh-autosuggestions zinit)' >> ~/.zshrc

# -----------------------------
# 12. Done
# -----------------------------
echo "✅ Setup complete! Please reboot your system or start a new Zsh session to apply changes."
