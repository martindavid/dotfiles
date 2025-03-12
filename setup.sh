#!/bin/bash

# Function to update and upgrade the system
prerequisites() {
  echo "Updating system..."
  sudo apt update && sudo apt upgrade -y


  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Create .bin directory..."
    mkdir ~/.bin
  fi
}

# Function to install required apt packages
install_apt_packages() {
  echo "Installing required packages..."
  sudo apt install -y zsh git build-essential libtool libtool-bin \
    autoconf automake cmake g++ pkg-config unzip curl gettext libevent-dev bison

  echo "Required packages installed!"
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
  echo "Installing Oh My Zsh..."
  # Check if zsh is already the default shell
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s $(which zsh)
  fi
  # Install Oh My Zsh if not already installed
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # install auto-sugegestions plugin if not exist
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  fi

  rm ~/.zshrc
  ln -s ~/dotfiles/.zshrc ~/.zshrc
  echo "Oh My Zsh installed!"
}

# Function to install fzf
install_fzf() {
  echo "Installing fzf..."
  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
  fi
  echo "fzf installed!"
}

install_neovim() {
  echo "Removing existing Neovim..."
  sudo apt remove neovim neovim-runtime

  echo "Installing Neovim from source..."
  if command -v nvim >/dev/null 2>&1; then
    echo "Neovim is installed"
  else
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo tar -C $HOME/.bin -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
    ln -s ~/.bin/nvim-linux-x86_64/bin/nvim ~/.bin/nvim
    ln -s ~/dotfiles/neovim ~/.config/nvim
  fi
}

install_lazygit() {
  echo "Installing lazygit..."
  if command -v lazygit >/dev/null 2>&1; then echo "lazygit is installed"
  else
    cd ~
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    rm lazygit.tar.gz
    sudo install lazygit -D -t ~/.bin
  fi
}

install_tmux() {
  echo "Installing tmux..."
  if command -v tmux >/dev/null 2>&1; then
    echo "lazygit is installed"
  else
    sudo apt install -y tmux
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  echo "tmux installed!"

  echo "Installing tmuxp"
  sudo apt install tmuxp

  ln -s ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
}

install_eza() {
  echo "Installing eza"
  if command -v eza >/dev/null 2>&1; then
    echo "eza is installed"
  else
    wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
    sudo chmod +x eza
    sudo chown root:root eza
    sudo mv eza ~/.bin/eza
  fi
}

main() {
  echo "Setting up the system..."
  prerequisites
  install_apt_packages
  install_oh_my_zsh
  install_fzf
  install_neovim
  install_lazygit
  install_tmux
  install_eza
  echo "Setup complete!"
}

main
