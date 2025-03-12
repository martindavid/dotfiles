#!/bin/bash

set -x

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
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/master/tools/install.sh)"
  fi

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
  if [ ! -d "$HOME/neovim" ]; then
    git clone https://github.com/neovim/neovim.git ~/neovim
  fi
  cd ~/neovim
  git checkout stable
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
  ln -s ~/neovim/build/bin/nvim ~/.bin/nvim
  ln -s ~/dotfiles/neovim ~/.config/nvim
}

install_lazygit() {
  echo "Installing lazygit..."
  if command -v lazygit >/dev/null 2>&1; then
    echo "lazygit is installed"
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

  ln -s ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
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
  echo "Setup complete!"
}

main
