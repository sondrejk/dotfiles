
# TMUX related
if [ -z "$TMUX" ] && [ "$TERM" != "screen" ] && [ -n "$PS1" ]; then
        tmux attach-session -t main || tmux new-session -s main
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# List of plugins used
plugins=( git sudo ssh-agent docker fzf zoxide pyenv)

export EDITOR='vim'
export PASSWORD_STORE_DIR="/home/sondrejk/repos/webkom/password-store"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export ZSH=~/.oh-my-zsh

source $ZSH/oh-my-zsh.sh
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

ZOXIDE_CMD_OVERRIDE="cd"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Helpful aliases
alias c='clear' # clear terminal
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto -l' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias lt='eza --icons=auto --tree' # list folder as tree
alias vc='code' # gui code editor
alias lg="lazygit"
alias ld="lazydocker"
alias xclip="xclip -selection c" # Xclip alias
alias mux="tmuxinator"
alias tmuxconf="$EDITOR ~/.tmux.conf"
alias zshconf="$EDITOR ~/.zshrc"
alias mkdir='mkdir -p'
alias cpwez="cp -r ~/repos/personal/dotfiles/wezterm /mnt/c/Users/sondr/.config"
# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# SSH AGENT CONFIG
zstyle :omz:plugins:ssh-agent agent-forwarding yes
zstyle :omz:plugins:ssh-agent identities personlig_id_ed25519 gammel_id_rsa
zstyle :omz:plugins:ssh-agent quiet yes
# zstyle :omz:plugins:ssh-agent lazy no

eval "$(pyenv init --path)"
