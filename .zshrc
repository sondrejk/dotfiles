
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

# DEFAULT EDITOR
export EDITOR='vim'

# SSH AGENT CONFIG
zstyle :omz:plugins:ssh-agent agent-forwarding yes
zstyle :omz:plugins:ssh-agent identities personlig_id_ed25519 gammel_id_rsa
zstyle :omz:plugins:ssh-agent quiet yes
# zstyle :omz:plugins:ssh-agent lazy no

# List of plugins used
plugins=( git sudo ssh-agent )

export ZSH=~/.oh-my-zsh
source $ZSH/oh-my-zsh.sh



# Helpful aliases
alias c='clear' # clear terminal
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias lt='eza --icons=auto --tree' # list folder as tree
alias vc='code' # gui code editor
alias lg="lazygit"
alias ld="lazydocker"
alias xclip="xclip -selection c" # Xclip alias
alias cd="z"
alias mux="tmuxinator"

# ALIASES FOR CONFIGS
alias tmuxconf="$EDITOR ~/.tmux.conf"
alias zshconf="$EDITOR ~/.zshrc"

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# ZOXIDE
eval "$(zoxide init zsh)"

# PASS settings
. "$HOME/.local/bin/env"
export PASSWORD_STORE_DIR="/home/sondrejk/repos/webkom/password-store"

## Webkom's .zshrc-config
webkom_dotfiles_dir='/home/sondrejk/repos/webkom/dotfiles'
source $webkom_dotfiles_dir/.zshrc

# FZF history
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
