#!/bin/bash
#
# setup-macos.sh — Dotfiles bootstrap for macOS Tahoe (26+) using Homebrew
#
# This is the macOS equivalent of setup.sh (which targets Debian/Ubuntu).
# It installs and configures the same toolchain via Homebrew and symlinks
# all dotfiles from ~/dotfiles into their expected locations.
#
# Usage:
#   chmod +x setup-macos.sh
#   ./setup-macos.sh
#
# Requirements:
#   - macOS Tahoe (26.x) or later
#   - Internet connection
#   - This repo cloned to ~/dotfiles
#

set -euo pipefail

# ─── Colour helpers ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ─── Prerequisites ───────────────────────────────────────────────────────────
# Ensure Xcode Command Line Tools and Homebrew are present.
prerequisites() {
  info "Checking prerequisites…"

  # 1. Xcode Command Line Tools (required by Homebrew and native compilation)
  if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools…"
    xcode-select --install
    # Wait for the installer to finish before continuing
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
    info "Xcode Command Line Tools installed!"
  else
    info "Xcode Command Line Tools already installed."
  fi

  # 2. Homebrew
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to the current shell session so subsequent commands work.
    # On Apple Silicon Macs, brew lives under /opt/homebrew; on Intel, /usr/local.
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    info "Homebrew installed!"
  else
    info "Homebrew already installed."
  fi

  # 3. Update Homebrew formulae
  info "Updating Homebrew…"
  brew update

  # 4. Create ~/.bin directory (mirrors the Linux setup)
  if [[ ! -d "$HOME/.bin" ]]; then
    info "Creating ~/.bin directory…"
    mkdir -p "$HOME/.bin"
  fi
}

# ─── Brew packages ───────────────────────────────────────────────────────────
# Installs the core CLI packages that the Linux setup installs via apt.
# macOS already ships with libtool, bison, curl, etc. via Xcode CLT,
# so we only install what is missing or where a newer version is needed.
install_brew_packages() {
  info "Installing required Homebrew packages…"

  local packages=(
    zsh
    git         # replaces the ancient Apple-bundled git (/usr/bin/git)
    cmake
    pkg-config
    curl
    gettext
    libevent
    fd          # equivalent of fd-find on Debian
    ripgrep     # commonly used alongside fd/fzf
    mise        # replaces `curl https://mise.run | sh`
    git-delta   # prettier diffs for lazygit and git-fuzzy
    gh          # GitHub CLI — create PRs, issues, manage repos from terminal
    zoxide      # smarter cd — jumps to frecency-ranked directories
    atuin       # shell history sync with fuzzy search across machines
    starship    # fast, informative cross-shell prompt (replaces robbyrussell)
    btop        # modern interactive system monitor (CPU, memory, network, disk)
  )

  brew install "${packages[@]}"

  # Explicitly link Homebrew git so it shadows the macOS system git (/usr/bin/git).
  # macOS SIP protects /usr/bin so we cannot overwrite it; instead we ensure
  # /opt/homebrew/bin (managed by brew shellenv) is earlier in PATH.
  # `brew link --overwrite git` forces symlinks into Homebrew's bin prefix.
  brew link --overwrite git

  # Verify the active git is the Homebrew one
  local active_git
  active_git="$(command -v git)"
  if [[ "$active_git" == /opt/homebrew/* ]] || [[ "$active_git" == /usr/local/* ]]; then
    info "Homebrew git is active: $(git --version) at $active_git"
  else
    warn "System git may still be active ($active_git). Restart your terminal after setup."
  fi

  info "Required Homebrew packages installed!"
}

# ─── Oh My Zsh ───────────────────────────────────────────────────────────────
install_oh_my_zsh() {
  info "Setting up Oh My Zsh…"

  # Set zsh as the default shell if it isn't already
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    info "Changing default shell to zsh…"
    chsh -s "$(which zsh)"
  fi

  # Install Oh My Zsh if not already present
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # Install zsh-autosuggestions plugin if not already present
  if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  fi

  # Symlink .zshrc (remove any existing file first)
  rm -f "$HOME/.zshrc"
  ln -s "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"

  info "Oh My Zsh installed!"
}

# ─── fzf ─────────────────────────────────────────────────────────────────────
# On macOS we prefer the Homebrew-managed version over a git-clone install.
# Shell integration (key bindings + fuzzy completion) is handled by adding
# `source <(fzf --zsh)` to .zshrc (available since fzf 0.48.0+), so we
# no longer need to run the legacy $(brew --prefix)/opt/fzf/install script.
install_fzf() {
  info "Installing fzf…"

  if ! command -v fzf &>/dev/null; then
    brew install fzf
  else
    info "fzf already installed."
  fi

  info "fzf installed!"
}

# ─── Neovim ──────────────────────────────────────────────────────────────────
# The Linux script downloads a pre-built tarball; Homebrew provides a
# universal (ARM + Intel) bottle that stays up to date with `brew upgrade`.
install_neovim() {
  info "Installing Neovim…"

  if ! command -v nvim &>/dev/null; then
    brew install neovim
  else
    info "Neovim already installed."
  fi

  # Symlink the Neovim config directory
  if [[ ! -L "$HOME/.config/nvim" && ! -d "$HOME/.config/nvim" ]]; then
    mkdir -p "$HOME/.config"
    ln -s "$HOME/dotfiles/neovim" "$HOME/.config/nvim"
  elif [[ -L "$HOME/.config/nvim" ]]; then
    info "Neovim config symlink already exists."
  else
    warn "~/.config/nvim exists and is not a symlink — skipping. Remove it manually if you want the dotfiles version."
  fi

  info "Neovim setup complete!"
}

# ─── lazygit ─────────────────────────────────────────────────────────────────
install_lazygit() {
  info "Installing lazygit…"

  if ! command -v lazygit &>/dev/null; then
    brew install lazygit
  else
    info "lazygit already installed."
  fi

  # Symlink lazygit config
  local lazygit_config_dir="$HOME/Library/Application Support/lazygit"
  if [[ ! -d "$lazygit_config_dir" ]]; then
    mkdir -p "$lazygit_config_dir"
  fi
  if [[ ! -L "$lazygit_config_dir/config.yml" ]]; then
    ln -sf "$HOME/dotfiles/lazygit/config.yml" "$lazygit_config_dir/config.yml"
  fi

  info "lazygit installed!"
}

# ─── tmux ────────────────────────────────────────────────────────────────────
install_tmux() {
  info "Installing tmux…"

  if ! command -v tmux &>/dev/null; then
    brew install tmux
  else
    info "tmux already installed."
  fi

  # Install TPM (Tmux Plugin Manager) if not present
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  # Install tmuxp (tmux session manager) — available in Homebrew Core
  info "Installing tmuxp…"
  brew install tmuxp

  # Symlink tmux config
  rm -f "$HOME/.tmux.conf"
  ln -s "$HOME/dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"

  # NOTE: The dotfiles tmux.conf uses xsel for copy-pipe (Linux).
  # On macOS, tmux-yank plugin auto-detects pbcopy, so no config
  # change is needed — the tmux-yank plugin handles this correctly.

  info "tmux installed!"
}

# ─── eza ─────────────────────────────────────────────────────────────────────
# Modern replacement for ls — the Linux script downloads a tarball;
# on macOS Homebrew provides a universal bottle.
install_eza() {
  info "Installing eza…"

  if ! command -v eza &>/dev/null; then
    brew install eza
  else
    info "eza already installed."
  fi

  info "eza installed!"
}

# ─── AeroSpace ───────────────────────────────────────────────────────────────
# AeroSpace is a macOS-only tiling window manager — not present in the
# Linux setup.sh but part of this dotfiles repo.
install_aerospace() {
  info "Installing AeroSpace…"

  if ! command -v aerospace &>/dev/null; then
    brew install --cask nikitabobko/tap/aerospace
  else
    info "AeroSpace already installed."
  fi

  # Symlink AeroSpace config
  if [[ ! -L "$HOME/.aerospace.toml" ]]; then
    ln -sf "$HOME/dotfiles/.aerospace.toml" "$HOME/.aerospace.toml"
  fi

  info "AeroSpace installed!"
}

# ─── git-fuzzy ───────────────────────────────────────────────────────────────
# Interactive git CLI used by the .zshrc aliases (gs, gd, glog).
# Not available via Homebrew — must be cloned from source.
# Requires fzf (already installed above). Optional: delta, bat, eza.
install_git_fuzzy() {
  info "Installing git-fuzzy…"

  local install_dir="$HOME/.local/share/git-fuzzy"

  if [[ -d "$install_dir" ]]; then
    info "git-fuzzy already installed — pulling latest…"
    git -C "$install_dir" pull --quiet
  else
    mkdir -p "$HOME/.local/share"
    git clone https://github.com/bigH/git-fuzzy.git "$install_dir"
  fi

  info "git-fuzzy installed!"
}

# ─── Fonts ───────────────────────────────────────────────────────────────────
# Install Nerd Fonts via Homebrew casks.
# SauceCodePro Nerd Font is referenced in the Ghostty config (font-family).
# Homebrew serves fonts from homebrew/cask (merged from cask-fonts in 4.x).
install_fonts() {
  info "Installing fonts…"

  local font_casks=(
    font-sauce-code-pro-nerd-font   # SauceCodePro Nerd Font — used by Ghostty config
  )

  brew install --cask "${font_casks[@]}"

  info "Fonts installed!"
}

# ─── Ghostty ─────────────────────────────────────────────────────────────────
# Ghostty is a GPU-accelerated terminal emulator. Its config lives at
# ~/.config/ghostty/config (XDG-compliant, no extension).
install_ghostty_config() {
  info "Symlinking Ghostty config…"

  local ghostty_config_dir="$HOME/.config/ghostty"
  local ghostty_config="$ghostty_config_dir/config"
  mkdir -p "$ghostty_config_dir"

  if [[ -L "$ghostty_config" ]]; then
    info "Ghostty config symlink already exists."
  elif [[ -f "$ghostty_config" ]]; then
    warn "~/.config/ghostty/config exists and is not a symlink — backing it up as config.bak"
    mv "$ghostty_config" "${ghostty_config}.bak"
    ln -sf "$HOME/dotfiles/ghostty/config" "$ghostty_config"
  else
    ln -sf "$HOME/dotfiles/ghostty/config" "$ghostty_config"
  fi

  info "Ghostty config symlinked!"
}

# ─── starship ────────────────────────────────────────────────────────────────
# Symlink the starship prompt config from the dotfiles repo.
# Starship reads ~/.config/starship.toml by default.
install_starship_config() {
  info "Symlinking starship config…"

  local starship_config="$HOME/.config/starship.toml"
  mkdir -p "$HOME/.config"

  if [[ -L "$starship_config" ]]; then
    info "starship.toml symlink already exists."
  elif [[ -f "$starship_config" ]]; then
    warn "~/.config/starship.toml exists and is not a symlink — backing it up as starship.toml.bak"
    mv "$starship_config" "${starship_config}.bak"
    ln -sf "$HOME/dotfiles/starship.toml" "$starship_config"
  else
    ln -sf "$HOME/dotfiles/starship.toml" "$starship_config"
  fi

  info "starship config symlinked!"
}

# ─── bat (optional but referenced in .zshrc) ─────────────────────────────────
# The .zshrc aliases `cat` to `bat` when available, so install it.
install_bat() {
  info "Installing bat…"

  if ! command -v bat &>/dev/null; then
    brew install bat
  else
    info "bat already installed."
  fi

  info "bat installed!"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo ""
  info "============================================="
  info "  macOS Tahoe Dotfiles Setup (Homebrew)      "
  info "============================================="
  echo ""

  prerequisites
  install_brew_packages
  install_oh_my_zsh
  install_fzf
  install_neovim
  install_lazygit
  install_tmux
  install_eza
  install_fonts
  install_aerospace
  install_git_fuzzy
  install_ghostty_config
  install_starship_config
  install_bat

  echo ""
  info "============================================="
  info "  Setup complete!                            "
  info "============================================="
  info ""
  info "Next steps:"
  info "  1. Restart your terminal (or run: source ~/.zshrc)"
  info "  2. Open tmux and press 'prefix + I' to install tmux plugins via TPM"
  info "  3. Open Neovim — Lazy.nvim will auto-install plugins on first launch"
  info "  4. Launch AeroSpace from Applications or enable 'start-at-login'"
  info "  5. Run 'tmuxp load /path/to/workspace.yaml' to start a tmuxp session"
  echo ""
}

main
