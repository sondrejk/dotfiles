# Powerlevel10k instant prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Auto-start tmux only in a real interactive terminal
if [[ -o interactive && -t 0 && -t 1 && -z "$TMUX" && "$TERM" != screen* && "$TERM" != tmux* ]]; then
  tmux attach-session -t main || tmux new-session -s main
fi
# Environment
export DOCKER_BUILDKIT=1
export EDITOR='nvim'
export PASSWORD_STORE_DIR="$HOME/repos/webkom/password-store"
export PYENV_ROOT="$HOME/.pyenv"
export ZSH="$HOME/.oh-my-zsh"
# PATH
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.local/share/pipx/venvs/ansible-core/bin"
  "$PYENV_ROOT/bin"
  $path
)
# Oh My Zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  sudo
  ssh-agent
  docker
  fzf
  zoxide
  pyenv
  vi-mode
)

# ENABLE_CORRECTION="true"

# SSH agent config
zstyle :omz:plugins:ssh-agent agent-forwarding yes
zstyle :omz:plugins:ssh-agent identities \
  id_ed25519_personlig \
  id_rsa_gammel \
  id_ed25519_hetzner \
  id_rsa_kvasir
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent lazy no
source "$ZSH/oh-my-zsh.sh"

# vi-mode settings (must come after sourcing oh-my-zsh.sh)
export KEYTIMEOUT=1
VI_MODE_SET_CURSOR=true
bindkey '^R' fzf-history-widget

# Optional external tools
[[ -r /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# eval $(thefuck --alias)

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# Helpful aliases
alias c='clear'
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto -l'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias lt='eza --icons=auto --tree'
alias vc='code'
alias lg='lazygit'
alias ld='lazydocker'
alias j='z'
alias xclip='xclip -selection c'
alias mux='tmuxp load'
alias tmuxconf="$EDITOR ~/.tmux.conf"
alias zshconf="$EDITOR ~/.zshrc"
alias kittyconf="$EDITOR ~/.config/kitty/kitty.conf"
alias mkdir='mkdir -p'
alias cpwez='cp -r ~/repos/personal/dotfiles/wezterm /mnt/c/Users/sondr/.config'
# Kubectl aliases
[ -f ~/.config/zsh/kubectl_aliases ] && source ~/.config/zsh/kubectl_aliases
# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
# Use kitty ssh kitten when running inside kitty (forwards terminfo, shell integration, etc.)
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="kitty +kitten ssh"
# Functions
ghclone() {
  local repo
  {
    # your personal repos
    gh repo list --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner'
    # repos from every org you're a member of
    gh api user/orgs --jq '.[].login' | while read -r org; do
      gh repo list "$org" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner'
    done
  } | sort -u | fzf | { read -r repo; [ -n "$repo" ] && print -z "git clone git@github.com:${repo}.git"; }
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
