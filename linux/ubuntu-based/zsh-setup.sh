#!/bin/bash

LOG_FILE="$(dirname "$0")/setup_errors.log"
touch "$LOG_FILE"

echo "🔧 Starting Zsh Setup..."
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

# 1. Install FiraCode Nerd Font if not already installed
FONT_DIR="$HOME/.local/share/fonts"
FONT_FILE="$FONT_DIR/FiraCodeNerdFont-Regular.ttf"

# Check if the font is already installed
if [ -f "$FONT_FILE" ]; then
  echo "✅ FiraCode Nerd Font is already installed."
else
  echo "❌ FiraCode Nerd Font not found, installing..."
  
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip"
  
  # Download the font zip
  curl -L -o "$FONT_DIR/FiraCodeNerdFont.zip" "$FONT_URL"
  
  # Create font directory if it doesn't exist
  mkdir -p "$FONT_DIR"
  
  # Unzip and install the font
  unzip "$FONT_DIR/FiraCodeNerdFont.zip" -d "$FONT_DIR"
  rm "$FONT_DIR/FiraCodeNerdFont.zip"
  
  # Refresh font cache
  fc-cache -fv
  
  echo "✅ FiraCode Nerd Font installed."
fi

# 2. Set FiraCode Nerd Font in Tilix
run_step "Setting FiraCode Nerd Font in Tilix" bash -c '
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/ font "FiraCode Nerd Font 12"
  echo "✅ FiraCode Nerd Font applied to Tilix"
'

# 3. Install Zsh if not already installed
if [ "$SHELL" = "$(which zsh)" ]; then
  echo "✅ Zsh is already the default shell. Skipping Zsh installation steps..."
  SKIP_ZSH=true
else
  SKIP_ZSH=false
fi

if [ "$SKIP_ZSH" = false ]; then
  # Install Zsh
  run_step "Installing Zsh" sudo apt install -y zsh

  # Change default shell to Zsh (interactive)
  run_step "Setting Zsh as default shell" chsh -s "$(which zsh)"

  # Install Oh My Zsh
  run_step "Installing Oh My Zsh" bash -c '
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || echo "⚠️ Oh My Zsh install might require manual setup." >> "$LOG_FILE"
  else
    echo "✅ Oh My Zsh is already installed"
  fi
  '

  # Install Zsh Plugins
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

  # Install Powerlevel10k theme
  run_step "Installing Powerlevel10k theme" bash -c '
  if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
  else
    echo "✅ Powerlevel10k theme is already installed"
  fi
  '

  # Modify .zshrc
  run_step "Updating .zshrc config" bash -c '
  if ! grep -q "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" ~/.zshrc; then
    sed -i "s|ZSH_THEME=.*|ZSH_THEME=\"powerlevel10k/powerlevel10k\"|" ~/.zshrc
    echo -e "\nplugins=(git zsh-syntax-highlighting zsh-autosuggestions zinit)" >> ~/.zshrc
  else
    echo "✅ .zshrc is already updated"
  fi
  '
fi

# 4. Install Flatpak apps (Telegram, VLC)
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

# 5. Reboot or restart terminal to apply changes
echo "✅ Setup completed! Please reboot or open a new terminal to start using Zsh with the applied settings."

echo "📄 Errors (if any) are logged in: $LOG_FILE"
