#!/bin/bash
#
# reset-macos.sh — Remove all dotfile symlinks and tool configs installed
#                  by setup-macos.sh, restoring the machine to a clean state.
#
# This script does NOT uninstall Homebrew or any brew packages — only the
# config symlinks and cloned repos (Oh My Zsh, TPM, git-fuzzy) are removed.
# After running this, your terminal will use macOS defaults.
#
# Usage:
#   chmod +x reset-macos.sh
#   ./reset-macos.sh
#
# Safe to run multiple times — every removal is guarded.
#

# ─── Colour helpers ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ─── Helper: safe removal ───────────────────────────────────────────────────
# Removes a file or symlink if it exists, with a descriptive message.
safe_rm() {
  local target="$1"
  local label="${2:-$target}"

  if [[ -L "$target" ]]; then
    rm -f "$target"
    info "Removed symlink: $label"
  elif [[ -f "$target" ]]; then
    rm -f "$target"
    info "Removed file: $label"
  else
    info "Already absent: $label"
  fi
}

# Removes a directory if it exists.
safe_rmdir() {
  local target="$1"
  local label="${2:-$target}"

  if [[ -d "$target" ]]; then
    rm -rf "$target"
    info "Removed directory: $label"
  else
    info "Already absent: $label"
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo ""
  info "============================================="
  info "  macOS Dotfiles Reset                       "
  info "============================================="
  echo ""
  warn "This will remove all dotfile symlinks and tool configs."
  warn "Homebrew packages will NOT be uninstalled."
  echo ""

  # Prompt for confirmation
  read -rp "Are you sure you want to continue? (y/N) " confirm
  if [[ "$confirm" != [yY] ]]; then
    info "Aborted."
    exit 0
  fi

  echo ""

  # ── 1. Shell config ─────────────────────────────────────────────────────
  info "── Removing shell configs ──"
  safe_rm "$HOME/.zshrc" "~/.zshrc"

  # ── 2. Oh My Zsh ───────────────────────────────────────────────────────
  info "── Removing Oh My Zsh ──"
  safe_rmdir "$HOME/.oh-my-zsh" "~/.oh-my-zsh"

  # ── 3. tmux ────────────────────────────────────────────────────────────
  info "── Removing tmux configs ──"
  safe_rm "$HOME/.tmux.conf" "~/.tmux.conf"
  safe_rmdir "$HOME/.tmux/plugins/tpm" "~/.tmux/plugins/tpm"

  # ── 4. Neovim ──────────────────────────────────────────────────────────
  info "── Removing Neovim config ──"
  if [[ -L "$HOME/.config/nvim" ]]; then
    rm -f "$HOME/.config/nvim"
    info "Removed symlink: ~/.config/nvim"
  elif [[ -d "$HOME/.config/nvim" ]]; then
    warn "~/.config/nvim is a directory (not a symlink) — skipping to be safe."
    warn "Remove it manually if needed: rm -rf ~/.config/nvim"
  else
    info "Already absent: ~/.config/nvim"
  fi

  # ── 5. lazygit ─────────────────────────────────────────────────────────
  info "── Removing lazygit config ──"
  safe_rm "$HOME/Library/Application Support/lazygit/config.yml" "~/Library/Application Support/lazygit/config.yml"

  # ── 6. AeroSpace ───────────────────────────────────────────────────────
  info "── Removing AeroSpace config ──"
  safe_rm "$HOME/.aerospace.toml" "~/.aerospace.toml"

  # ── 7. Ghostty ─────────────────────────────────────────────────────────
  info "── Removing Ghostty config ──"
  safe_rm "$HOME/.config/ghostty/config" "~/.config/ghostty/config"
  # Restore backup if one exists
  if [[ -f "$HOME/.config/ghostty/config.bak" ]]; then
    mv "$HOME/.config/ghostty/config.bak" "$HOME/.config/ghostty/config"
    info "Restored Ghostty config from backup."
  fi

  # ── 8. Starship ────────────────────────────────────────────────────────
  info "── Removing Starship config ──"
  safe_rm "$HOME/.config/starship.toml" "~/.config/starship.toml"
  # Restore backup if one exists
  if [[ -f "$HOME/.config/starship.toml.bak" ]]; then
    mv "$HOME/.config/starship.toml.bak" "$HOME/.config/starship.toml"
    info "Restored Starship config from backup."
  fi

  # ── 9. git-fuzzy ───────────────────────────────────────────────────────
  info "── Removing git-fuzzy ──"
  safe_rmdir "$HOME/.local/share/git-fuzzy" "~/.local/share/git-fuzzy"

  # ── 10. Restore default shell ──────────────────────────────────────────
  info "── Restoring default shell ──"
  if [[ "$SHELL" != "/bin/zsh" ]]; then
    info "Changing default shell back to /bin/zsh (macOS default)…"
    chsh -s /bin/zsh
  else
    info "Default shell is already /bin/zsh."
  fi

  echo ""
  info "============================================="
  info "  Reset complete!                            "
  info "============================================="
  echo ""
  info "Your machine is back to macOS defaults."
  info "Restart your terminal for changes to take effect."
  echo ""
  info "To re-run the dotfiles setup:"
  info "  cd ~/dotfiles && ./setup-macos.sh"
  echo ""
}

main
