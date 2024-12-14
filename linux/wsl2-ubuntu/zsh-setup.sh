#!/bin/bash

# Update and install required packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y zsh curl git

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# Set Zsh as the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting Zsh as default shell..."
    chsh -s $(which zsh)
fi

# Install plugins for Oh My Zsh
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
PLUGINS=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" "python")

echo "Installing plugins..."
mkdir -p $ZSH_CUSTOM/plugins

git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions

# Update .zshrc with plugin configurations
if ! grep -q "plugins=(.*zsh-autosuggestions.*)" ~/.zshrc; then
    echo "Updating .zshrc with plugins..."
    sed -i "/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions python)" ~/.zshrc
fi

# Apply changes to the current session
source ~/.zshrc

echo "Zsh and Oh My Zsh setup completed! Restart your terminal to use Zsh as the default shell."
