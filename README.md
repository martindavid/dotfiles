# Martin's DotFiles

Personal dotfiles for macOS (Tahoe 26+) with a Linux fallback. Installs and symlinks a complete terminal development environment: Zsh + Oh My Zsh, Neovim (AstroNvim v5+), tmux, Ghostty, lazygit, and a curated set of modern CLI tools.

## Setup

### macOS

```bash
./setup-macos.sh
```

### Linux / Debian

```bash
./setup.sh
```

To remove all symlinks and cloned repos (without uninstalling Homebrew packages):

```bash
./reset-macos.sh
```

> Both scripts are idempotent — safe to run multiple times. Existing files are backed up with a `.bak` extension before being overwritten.

## Language Runtimes (via mise)

```bash
mise install node@latest
mise install go@latest
mise install python@latest
mise install ruby@latest
```

## Symlink Targets

| Config | Target |
|---|---|
| `~/.zshrc` | `dotfiles/.zshrc` |
| `~/.config/nvim` | `dotfiles/neovim/` |
| `~/.config/tmux/tmux.conf` | `dotfiles/tmux/tmux.conf` |
| `~/.config/ghostty/config` | `dotfiles/ghostty/config` |
| `~/Library/Application Support/lazygit/config.yml` | `dotfiles/lazygit/config.yml` |

All changes should be made in this repo — they take effect immediately via symlinks.

## Neovim

Config lives in `neovim/`. Entry point is `neovim/init.lua`, which bootstraps Lazy.nvim. Plugin configs are in `neovim/lua/plugins/`. LSP setup is in `astrolsp.lua` and key mappings in `mappings.lua`.

## Shell

- Homebrew's Zsh with Oh My Zsh
- Plugins: `zsh-autosuggestions`, `zsh-interactive-cd`, `git`
- Starship for the prompt (no Oh My Zsh theme)
- Apple Silicon Homebrew path (`/opt/homebrew`) set explicitly

## Tools

| Tool | Purpose |
|---|---|
| `mise` | Language version manager (Node, Go, Python, Ruby) |
| `starship` | Shell prompt |
| `zoxide` | Frecency-based `cd` replacement |
| `atuin` | Shell history with sync |
| `fzf` | Fuzzy finder |
| `fd` / `ripgrep` | Fast find/grep alternatives |
| `eza` | Colorized `ls` replacement |
| `bat` | Syntax-highlighted `cat` |
| `git-fuzzy` | Interactive git TUI |
| `delta` | Prettier git diffs |
| `lazygit` | Full TUI git client |
| `btop` | System monitor |
| `tmuxp` | Tmux session manager (templates in `tmuxp/`) |
````


