# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles for macOS (Tahoe 26+) with a Linux fallback. Installs and symlinks a complete terminal development environment: Zsh + Oh My Zsh, Neovim (AstroNvim v5+), tmux, Ghostty, lazygit, and a curated set of modern CLI tools.

## Key Scripts

| Script | Purpose |
|---|---|
| `setup-macos.sh` | Primary setup for macOS — installs Homebrew packages, Oh My Zsh, symlinks all configs |
| `reset-macos.sh` | Removes all symlinks and cloned repos without uninstalling Homebrew packages |
| `setup.sh` | Linux/Debian fallback using `apt` |

### Running the macOS setup

```bash
./setup-macos.sh
```

No build step, linter, or test suite — these are shell scripts and config files.

### Installing language runtimes (via mise)

```bash
mise install node@latest
mise install go@latest
mise install python@latest
mise install ruby@latest
```

## Architecture

### Symlink Strategy

The setup script symlinks configs from the repo into their expected system locations (not copy). All changes should be made here in the repo — they take effect immediately because the symlinks point here.

Key symlink targets:
- `~/.zshrc` → `dotfiles/.zshrc`
- `~/.config/nvim` → `dotfiles/neovim/`
- `~/.config/tmux/tmux.conf` → `dotfiles/tmux/tmux.conf`
- `~/.config/ghostty/config` → `dotfiles/ghostty/config`
- `~/Library/Application Support/lazygit/config.yml` → `dotfiles/lazygit/config.yml`

### Idempotency

Both `setup-macos.sh` and `reset-macos.sh` are safe to run multiple times. The setup script uses `set -uo pipefail` (intentionally not `set -e`) so non-fatal Homebrew failures don't abort the full install. Before overwriting any existing file, it backs it up with a `.bak` extension.

### Neovim (AstroNvim v5+)

Config lives in `neovim/`. Entry point is `neovim/init.lua` which bootstraps Lazy.nvim. Plugin configs live in `neovim/lua/plugins/`. The `community.lua` file loads AstroNvim community modules. LSP setup is in `astrolsp.lua`, key mappings in `mappings.lua`.

### Language Management (mise)

`mise` is the single tool for managing Node, Go, Python, and Ruby versions — replacing nvm, rbenv, pyenv, etc. It supports both global and per-project `.mise.toml` files.

### Shell (.zshrc)

- Uses Homebrew's zsh
- Oh My Zsh with plugins: `zsh-autosuggestions`, `zsh-interactive-cd`, `git`
- Starship handles the prompt (no Oh My Zsh theme)
- Apple Silicon Homebrew path (`/opt/homebrew`) is set explicitly
- `git-fuzzy` bin is added to PATH for interactive git CLI

## Tool Reference

| Tool | Purpose |
|---|---|
| `mise` | Language version manager (Node, Go, Python, Ruby) |
| `starship` | Shell prompt |
| `zoxide` | Frecency-based `cd` replacement |
| `atuin` | Shell history with sync |
| `fzf` | Fuzzy finder (shell integration via Homebrew) |
| `fd` / `ripgrep` | Fast find/grep alternatives |
| `eza` | Colorized `ls` replacement |
| `bat` | Syntax-highlighted `cat` |
| `git-fuzzy` | Interactive git TUI (cloned to `~/.local/share/git-fuzzy`) |
| `delta` | Prettier git diffs |
| `lazygit` | Full TUI git client |
| `btop` | System monitor |
| `tmuxp` | Tmux session manager (templates in `tmuxp/`) |
