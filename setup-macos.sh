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

set -uo pipefail
# NOTE: We intentionally do NOT use `set -e` (errexit) because many
# Homebrew commands return non-zero for non-fatal reasons (e.g. "already
# installed", "already linked"). Instead, we check exit codes explicitly
# where failure matters.

# ─── Colour helpers ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ─── Resolve the dotfiles repo directory ─────────────────────────────────────
# Determine the absolute path of this script's directory so symlinks work
# regardless of where the repo is cloned (e.g. ~/dotfiles, ~/repos/dotfiles).
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Dotfiles directory: $DOTFILES_DIR"

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

  # Use --quiet to suppress noise for already-installed packages.
  # brew install returns 0 even if already installed when using formulae names.
  brew install "${packages[@]}" || warn "Some packages may have failed — check output above."

  # Explicitly link Homebrew git so it shadows the macOS system git (/usr/bin/git).
  # macOS SIP protects /usr/bin so we cannot overwrite it; instead we ensure
  # /opt/homebrew/bin (managed by brew shellenv) is earlier in PATH.
  brew link --overwrite git 2>/dev/null || true

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

  # Set Homebrew zsh as the default shell if it isn't already.
  # macOS's chsh requires the target shell to be listed in /etc/shells.
  # Homebrew's zsh (/opt/homebrew/bin/zsh) is not there by default,
  # so we append it first if missing, then call chsh.
  local brew_zsh
  brew_zsh="$(brew --prefix)/bin/zsh"

  if ! grep -qF "$brew_zsh" /etc/shells; then
    info "Adding $brew_zsh to /etc/shells…"
    echo "$brew_zsh" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$brew_zsh" ]]; then
    info "Changing default shell to Homebrew zsh ($brew_zsh)…"
    chsh -s "$brew_zsh"
  else
    info "Default shell is already Homebrew zsh."
  fi

  # Install Oh My Zsh if not already present.
  # RUNZSH=no   — don't launch zsh after install (we're mid-script).
  # KEEP_ZSHRC=yes — don't overwrite an existing .zshrc (we symlink our own below).
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # Install zsh-autosuggestions plugin if not already present.
  # Use explicit path instead of $ZSH_CUSTOM which is unset in bash context.
  local omz_custom="$HOME/.oh-my-zsh/custom"
  if [[ ! -d "$omz_custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "$omz_custom/plugins/zsh-autosuggestions"
  fi

  # Symlink .zshrc — use ln -sf to atomically replace any existing file/symlink.
  ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

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
  if [[ -L "$HOME/.config/nvim" ]] && [[ "$(readlink "$HOME/.config/nvim")" == "$DOTFILES_DIR/neovim" ]]; then
    info "Neovim config symlink already exists."
  elif [[ -L "$HOME/.config/nvim" ]]; then
    info "Neovim config symlink points elsewhere — relinking."
    ln -sf "$DOTFILES_DIR/neovim" "$HOME/.config/nvim"
  elif [[ ! -d "$HOME/.config/nvim" ]]; then
    mkdir -p "$HOME/.config"
    ln -s "$DOTFILES_DIR/neovim" "$HOME/.config/nvim"
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
  mkdir -p "$lazygit_config_dir"

  if [[ -L "$lazygit_config_dir/config.yml" ]] && [[ "$(readlink "$lazygit_config_dir/config.yml")" == "$DOTFILES_DIR/lazygit/config.yml" ]]; then
    info "lazygit config symlink already exists."
  elif [[ -L "$lazygit_config_dir/config.yml" ]]; then
    info "lazygit config symlink points elsewhere — relinking."
    ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$lazygit_config_dir/config.yml"
  elif [[ -f "$lazygit_config_dir/config.yml" ]]; then
    warn "lazygit config.yml exists and is not a symlink — backing it up as config.yml.bak"
    mv "$lazygit_config_dir/config.yml" "$lazygit_config_dir/config.yml.bak"
    ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$lazygit_config_dir/config.yml"
  else
    ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$lazygit_config_dir/config.yml"
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

  # Install all TPM plugins headlessly
  if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/" \
      "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
  fi

  # Install tmuxp (tmux session manager)
  info "Installing tmuxp…"
  brew install tmuxp || {
    warn "tmuxp not available via Homebrew — falling back to pipx…"
    if command -v pipx &>/dev/null; then
      pipx install tmuxp
    elif command -v pip3 &>/dev/null; then
      pip3 install --user tmuxp
    else
      warn "Could not install tmuxp — install manually later via 'pip3 install tmuxp'"
    fi
  }

  # Symlink tmux config — use ln -sf to atomically replace any existing file/symlink.
  ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

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
  if [[ -L "$HOME/.aerospace.toml" ]] && [[ "$(readlink "$HOME/.aerospace.toml")" == "$DOTFILES_DIR/.aerospace.toml" ]]; then
    info "AeroSpace config symlink already exists."
  elif [[ -L "$HOME/.aerospace.toml" ]]; then
    info "AeroSpace config symlink points elsewhere — relinking."
    ln -sf "$DOTFILES_DIR/.aerospace.toml" "$HOME/.aerospace.toml"
  elif [[ -f "$HOME/.aerospace.toml" ]]; then
    warn "~/.aerospace.toml exists and is not a symlink — backing it up as .aerospace.toml.bak"
    mv "$HOME/.aerospace.toml" "$HOME/.aerospace.toml.bak"
    ln -sf "$DOTFILES_DIR/.aerospace.toml" "$HOME/.aerospace.toml"
  else
    ln -sf "$DOTFILES_DIR/.aerospace.toml" "$HOME/.aerospace.toml"
  fi

  info "AeroSpace installed!"
}

# ─── Karabiner-Elements ──────────────────────────────────────────────────────
# Keyboard remapper — used to remap Caps Lock → Escape.
# Config lives at ~/.config/karabiner/karabiner.json (XDG-compliant).
install_karabiner() {
  info "Installing Karabiner-Elements…"

  if ! brew list --cask karabiner-elements &>/dev/null; then
    brew install --cask karabiner-elements
  else
    info "Karabiner-Elements already installed."
  fi

  local karabiner_config_dir="$HOME/.config/karabiner"
  local karabiner_config="$karabiner_config_dir/karabiner.json"
  mkdir -p "$karabiner_config_dir"

  if [[ -L "$karabiner_config" ]] && [[ "$(readlink "$karabiner_config")" == "$DOTFILES_DIR/karabiner/karabiner.json" ]]; then
    info "Karabiner config symlink already exists."
  elif [[ -L "$karabiner_config" ]]; then
    info "Karabiner config symlink points elsewhere — relinking."
    ln -sf "$DOTFILES_DIR/karabiner/karabiner.json" "$karabiner_config"
  elif [[ -f "$karabiner_config" ]]; then
    warn "~/.config/karabiner/karabiner.json exists and is not a symlink — backing it up as karabiner.json.bak"
    mv "$karabiner_config" "${karabiner_config}.bak"
    ln -sf "$DOTFILES_DIR/karabiner/karabiner.json" "$karabiner_config"
  else
    ln -sf "$DOTFILES_DIR/karabiner/karabiner.json" "$karabiner_config"
  fi

  info "Karabiner-Elements installed!"
  warn "NOTE: Karabiner requires accessibility + input monitoring permissions."
  warn "      Open System Settings → Privacy & Security and grant access if prompted."
}

# ─── Obsidian ────────────────────────────────────────────────────────────────
# Note-taking app — installed as a cask, no config to symlink (vaults are
# self-contained directories managed by the user).
install_obsidian() {
  info "Installing Obsidian…"

  if ! brew list --cask obsidian &>/dev/null; then
    brew install --cask obsidian
  else
    info "Obsidian already installed."
  fi

  info "Obsidian installed!"
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

  if [[ -L "$ghostty_config" ]] && [[ "$(readlink "$ghostty_config")" == "$DOTFILES_DIR/ghostty/config" ]]; then
    info "Ghostty config symlink already exists."
  elif [[ -L "$ghostty_config" ]]; then
    info "Ghostty config symlink points elsewhere — relinking."
    ln -sf "$DOTFILES_DIR/ghostty/config" "$ghostty_config"
  elif [[ -f "$ghostty_config" ]]; then
    warn "~/.config/ghostty/config exists and is not a symlink — backing it up as config.bak"
    mv "$ghostty_config" "${ghostty_config}.bak"
    ln -sf "$DOTFILES_DIR/ghostty/config" "$ghostty_config"
  else
    ln -sf "$DOTFILES_DIR/ghostty/config" "$ghostty_config"
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

  if [[ -L "$starship_config" ]] && [[ "$(readlink "$starship_config")" == "$DOTFILES_DIR/starship.toml" ]]; then
    info "starship.toml symlink already exists."
  elif [[ -L "$starship_config" ]]; then
    info "starship.toml symlink points elsewhere — relinking."
    ln -sf "$DOTFILES_DIR/starship.toml" "$starship_config"
  elif [[ -f "$starship_config" ]]; then
    warn "~/.config/starship.toml exists and is not a symlink — backing it up as starship.toml.bak"
    mv "$starship_config" "${starship_config}.bak"
    ln -sf "$DOTFILES_DIR/starship.toml" "$starship_config"
  else
    ln -sf "$DOTFILES_DIR/starship.toml" "$starship_config"
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

# ─── Languages (via mise) ────────────────────────────────────────────────────
# Install programming language runtimes via mise and any global packages
# required by tools (e.g. Neovim's Python/Ruby providers).
install_languages() {
  info "Installing language runtimes via mise…"

  if ! command -v mise &>/dev/null; then
    error "mise is not installed — skipping language installation."
    return 1
  fi

  # Activate mise in the current bash session so `mise install` and
  # the installed binaries are available immediately.
  eval "$(mise activate bash)"

  # Node.js (latest LTS)
  info "Installing Node.js (latest)…"
  mise use --global node@latest

  # Go (latest)
  info "Installing Go (latest)…"
  mise use --global go@latest

  # Python (latest) + neovim module for Neovim's :checkhealth
  info "Installing Python (latest)…"
  mise use --global python@latest

  info "Installing pynvim (Neovim Python provider)…"
  pip3 install --upgrade pynvim || warn "Failed to install pynvim — run 'pip3 install pynvim' manually."

  # Ruby (latest) + neovim gem for Neovim's :checkhealth
  info "Installing Ruby (latest)…"
  mise use --global ruby@latest

  info "Installing neovim gem (Neovim Ruby provider)…"
  gem install neovim || warn "Failed to install neovim gem — run 'gem install neovim' manually."

  # Verify installations
  echo ""
  info "Installed language versions:"
  info "  Node.js : $(node --version 2>/dev/null || echo 'not found')"
  info "  Go      : $(go version 2>/dev/null || echo 'not found')"
  info "  Python  : $(python3 --version 2>/dev/null || echo 'not found')"
  info "  Ruby    : $(ruby --version 2>/dev/null || echo 'not found')"
  echo ""

  info "Language runtimes installed!"
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
  install_karabiner
  install_obsidian
  install_git_fuzzy
  install_ghostty_config
  install_starship_config
  install_bat
  install_languages

  echo ""
  info "============================================="
  info "  Setup complete!                            "
  info "============================================="
  info ""
  info "Next steps:"
  info "  1. Restart your terminal (or run: source ~/.zshrc)"
  info "  3. Open Neovim — Lazy.nvim will auto-install plugins on first launch"
  info "  4. Launch AeroSpace from Applications or enable 'start-at-login'"
  info "  5. Run 'tmuxp load /path/to/workspace.yaml' to start a tmuxp session"
  echo ""
}

main
