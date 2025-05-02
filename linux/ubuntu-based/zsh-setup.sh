#!/bin/bash

LOG_FILE="$(dirname "$0")/setup_errors.log"
touch "$LOG_FILE"

echo "🔧 Starting Zsh setup..."
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
    return $STATUS  # Return the error status
  else
    echo "✅ $DESC completed successfully!"
  fi
}

# 1. Install FiraCode Nerd Font
run_step "Installing FiraCode Nerd Font" bash -c '
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip"
FONT_DIR="$HOME/.local/share/fonts"

# Download the font zip
curl -L -o "$FONT_DIR/FiraCodeNerdFont.zip" "$FONT_URL"

# Create font directory if it doesn't exist
mkdir -p "$FONT_DIR"

# Unzip and install the font
unzip "$FONT_DIR/FiraCodeNerdFont.zip" -d "$FONT_DIR"
rm "$FONT_DIR/FiraCodeNerdFont.zip"

# Refresh font cache
fc-cache -fv
'

# 2. Set FiraCode Nerd Font in Tilix
run_step "Setting FiraCode Nerd Font in Tilix" bash -c '
# Check if Tilix is installed
if command -v tilix &>/dev/null; then
  # Set the font to FiraCode Nerd Font in Tilix
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/ default "FiraCode Nerd Font"
  echo "✅ FiraCode Nerd Font applied to Tilix"
else
  echo "❌ Tilix not found. Please install Tilix manually."
  return 1  # Return an error if Tilix is not found
fi
'

# 3. Install Zsh plugins

# Zsh Syntax Highlighting
run_step "Installing Zsh syntax highlighting" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
  echo "✅ Zsh syntax highlighting is already installed"
fi
'

# Zsh Autosuggestions
run_step "Installing Zsh autosuggestions" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
  echo "✅ Zsh autosuggestions is already installed"
fi
'

# Zinit Plugin Manager
run_step "Installing Zinit plugin manager" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zinit" ]; then
  git clone https://github.com/zdharma-continuum/zinit.git ~/.oh-my-zsh/custom/plugins/zinit
else
  echo "✅ Zinit plugin manager is already installed"
fi
'

# Powerlevel10k Theme
run_step "Installing Powerlevel10k theme" bash -c '
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
else
  echo "✅ Powerlevel10k theme is already installed"
fi
'

# 4. Modify .zshrc to load plugins and theme
run_step "Updating .zshrc with plugins and theme" bash -c '
if ! grep -q "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" ~/.zshrc; then
  sed -i "s|ZSH_THEME=.*|ZSH_THEME=\"powerlevel10k/powerlevel10k\"|" ~/.zshrc
  echo -e "\nplugins=(git zsh-syntax-highlighting zsh-autosuggestions zinit)" >> ~/.zshrc
else
  echo "✅ .zshrc is already updated"
fi
'

echo -e "\n✅ Zsh setup completed!"
echo "📄 Errors (if any) are logged in: $LOG_FILE"
