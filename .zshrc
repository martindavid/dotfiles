# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$HOME/.bin:$PATH

# ─── Homebrew (Apple Silicon) ────────────────────────────────────────────────
# On Apple Silicon Macs, Homebrew installs to /opt/homebrew.
# The brew installer adds this to ~/.zprofile, but we also eval here so that
# non-login shells (e.g. tmux panes, IDE terminals) pick it up.
# Guard with -z check to avoid re-evaluating (and the ~50ms cost) in subshells
# where Homebrew is already on PATH (e.g. nested tmux panes).
#
# IMPORTANT: brew shellenv prepends /opt/homebrew/bin to PATH, which ensures
# Homebrew-managed tools (including git, curl, zsh) take precedence over the
# Apple-bundled versions in /usr/bin. This is intentional — e.g. Homebrew git
# is always current while macOS ships a frozen, older version via Xcode CLT.
if [[ -f /opt/homebrew/bin/brew ]] && [[ -z "$HOMEBREW_PREFIX" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ─── git-fuzzy ───────────────────────────────────────────────────────────────
# Cloned to ~/.local/share/git-fuzzy by setup-macos.sh
export PATH="$HOME/.local/share/git-fuzzy/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Disable OMZ theme — starship handles the prompt instead.
# Setting ZSH_THEME to an empty string tells OMZ not to set PS1,
# giving starship full control over the prompt rendering.
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Oh My Zsh update behaviour — notify me weekly, don't auto-update silently
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  zsh-autosuggestions
  zsh-interactive-cd
  git
  # gitfast removed — redundant since OMZ's git plugin was updated
)

source $ZSH/oh-my-zsh.sh

# ─── History ─────────────────────────────────────────────────────────────────
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000       # Lines kept in memory
export SAVEHIST=50000       # Lines persisted to HISTFILE

setopt HIST_IGNORE_DUPS     # Don't record a command already in history consecutively
setopt HIST_IGNORE_SPACE    # Prefix a command with a space to keep it out of history (e.g. secrets)
setopt HIST_SAVE_NO_DUPS    # Don't write duplicate entries to the history file
setopt HIST_FIND_NO_DUPS    # Skip duplicates when navigating history with Ctrl-R
setopt HIST_REDUCE_BLANKS   # Strip superfluous whitespace from history entries
setopt INC_APPEND_HISTORY   # Write to HISTFILE immediately, not on shell exit
setopt SHARE_HISTORY        # Share history across all concurrent zsh sessions (great for tmux)

# ─── Navigation ──────────────────────────────────────────────────────────────
setopt AUTO_CD              # Type a directory name to cd into it without typing 'cd'
setopt INTERACTIVE_COMMENTS # Allow # comments in interactive shell (useful for annotations)

# ─── Tool integrations ──────────────────────────────────────────────────────
# fzf: key bindings (CTRL-T, CTRL-R, ALT-C) and fuzzy completion
source <(fzf --zsh)

# fzf appearance and behaviour
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --info=inline --border"

# CTRL-T: search files — use fd for speed, bat for preview
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,.cache
  --preview 'bat -n --color=always {}'
  --preview-window 'right:55%:wrap'"

# ALT-C: search directories — use eza for tree preview
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,.cache
  --preview 'eza --tree --color=always --icons {}'"

# mise: runtime version manager activation (Node, Python, etc.)
eval "$(mise activate zsh)"

# zoxide: smarter cd with frecency-based directory jumping.
# `z <query>` jumps to the best match; `zi` opens an fzf picker.
# The --cmd cd flag makes zoxide replace `cd` entirely so muscle memory
# keeps working while silently getting the smarter behaviour.
eval "$(zoxide init zsh --cmd cd)"

# atuin: replaces shell history (Ctrl-R) with a fuzzy, syncable database.
# ATUIN_NOBIND=true disables atuin's default Ctrl-R binding so we can
# set it explicitly below, keeping control over key binding precedence.
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"
bindkey '^r' atuin-search   # Ctrl-R  → atuin fuzzy history search
bindkey '^[[A' atuin-up-search  # Up arrow → context-aware history search

# starship: initialise the prompt (must be last in shell integrations).
# Starship reads ~/.config/starship.toml for configuration.
eval "$(starship init zsh)"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

export EDITOR='nvim'

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias zshreload="source ~/.zshrc"
alias ll="eza -bhl --color always --icons -a -s type"
alias ls="eza -G --color auto --icons -a -s type"
alias lg="lazygit"
alias gsync="git fetch-afe && git rebase-afe"

if [ "$(command -v bat)" ]; then
  unalias -m 'cat'
  alias cat='bat -pp --theme="Nord"'
fi

# Git Fuzzy Alias
alias gs="git fuzzy status"
alias gd="git fuzzy diff"
alias glog="git fuzzy log"
