# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles. Each tool's config lives in this repo and is **symlinked** into its
expected location by a bootstrap script. The repo is expected to be cloned to `~/dotfiles`
(the Linux script hardcodes that path; the macOS script resolves its own location, so any
clone path works).

There is no build, package, or test suite. "Running" this repo means running a setup script,
then letting each tool pick up its symlinked config.

## Architecture: parallel bootstrap scripts + symlinks

Three top-level scripts manage installation, each idempotent and safe to re-run:

- `setup-macos.sh` — macOS (Tahoe 26+), installs via **Homebrew**. The canonical, most
  complete script (also handles AeroSpace, Ghostty, starship, fonts, git-fuzzy, mise languages).
- `setup.sh` — Debian/Ubuntu, installs via **apt** + source builds. The Linux counterpart.
- `reset-macos.sh` — removes only the symlinks and cloned helper repos created by
  `setup-macos.sh` (Oh My Zsh, TPM, git-fuzzy). Does **not** uninstall Homebrew packages.
  Restores `.bak` backups where setup created them.

`setup-macos.sh` and `setup.sh` are intentional mirrors of the same toolchain on two OSes.
**When you add or change a tool in one, update the other** unless the tool is OS-specific
(e.g. AeroSpace and `pbcopy` handling are macOS-only; some apt source-builds are Linux-only).

Setup scripts deliberately avoid `set -e` — Homebrew/apt commands often return non-zero for
non-fatal reasons ("already installed"). Exit codes are checked explicitly where failure matters.
Each config symlink is guarded: existing real files are backed up to `*.bak` before linking.

### Where configs are symlinked to

| Repo path | Symlinked to |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `neovim/` | `~/.config/nvim` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml` (macOS) |
| `ghostty/config` | `~/.config/ghostty/config` |
| `starship.toml` | `~/.config/starship.toml` |
| `.aerospace.toml` | `~/.aerospace.toml` |

Editing a config = editing the file in this repo (the symlink target). No copy step.

## Neovim (`neovim/`)

An **AstroNvim v6+** configuration managed by **Lazy.nvim**. Structure:

- `init.lua` — bootstraps Lazy.nvim, then `require "lazy_setup"` and `require "polish"`.
  Treat as untouchable boilerplate.
- `lua/lazy_setup.lua` — declares the AstroNvim base + imports the plugin specs.
- `lua/community.lua` — AstroCommunity plugin pack imports.
- `lua/plugins/*.lua` — one file per plugin/concern (e.g. `astrocore.lua` for options/mappings/
  autocmds, `astrolsp.lua` for LSP, `mason.lua` for tool installs, `treesitter.lua`, `none-ls.lua`,
  `disabled.lua` to turn off defaults). Each returns a Lazy plugin spec table.
- `lua/custom/` — local, non-plugin modules (e.g. `atlassian-avante.lua`).
- `lsp/*.lua` — per-server LSP config consumed via the Neovim 0.11+ `vim.lsp.config` mechanism
  (e.g. `lsp/vtsls.lua`).
- `lazy-lock.json` — the Lazy.nvim lockfile; commit changes to it when plugins update.

Lua formatting and linting (config files exist; run the tools directly):

```sh
stylua neovim/          # format — config in neovim/.stylua.toml (2-space, 120 col)
selene neovim/          # lint — config in neovim/selene.toml (std = "neovim")
```

`neovim/.luarc.json` and `.neoconf.json` disable lua_ls's own formatter so stylua owns formatting.
Plugins auto-install on first `nvim` launch; there is no separate install command.

## Do not touch: `tmuxp/`

`tmuxp/` is a **vendored clone of the upstream `github.com/tmux-python/tmuxp` project** and has
its own `.git`. It is not part of these dotfiles. Do not modify, lint, or refactor anything under
`tmuxp/`, and exclude it from repo-wide searches and edits.

## Post-setup manual steps

After `setup-macos.sh` (it prints these): restart the shell, install tmux plugins with
`prefix + I` (TPM), launch Neovim once for Lazy to install plugins, and start sessions with
`tmuxp load <workspace>.yaml`.
