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
  "$PYENV_ROOT/shims"
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

bindkey '^R' fzf-history-widget

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Optional external tools
[[ -r /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
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
  # every repo you can reach: your own, org repos, and ones shared with you as a collaborator
  local selected
  selected=$(
    gh api --paginate -X GET /user/repos \
      -f affiliation=owner,collaborator,organization_member \
      -f sort=pushed -f per_page=100 \
      --jq '.[].full_name' \
      | awk '!seen[$0]++' \
      | fzf --multi --prompt='clone> ' --header='tab/shift-tab to select multiple, enter to confirm'
  ) || return

  [[ -z "$selected" ]] && return

  local cmds="" repo
  while IFS= read -r repo; do
    cmds+="git clone git@github.com:${repo}.git"$'\n'
  done <<< "$selected"

  print -z "${cmds%$'\n'}"
}

reposcan() {
  setopt localoptions nomonitor
  local do_fetch=0 verbose=0 max_jobs=8
  local OPTIND opt
  while getopts "fvj:" opt; do
    case "$opt" in
      f) do_fetch=1 ;;
      v) verbose=1 ;;
      j) max_jobs="$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))
  local dir="${1:-$HOME/repos}"

  [[ "$do_fetch" -eq 1 ]] && echo "scanning ${dir/#$HOME/~} (fetching)..."

  local results
  results=$(mktemp)

  local running=0
  fd -H -t d -a '^\.git$' "$dir" 2>/dev/null | while IFS= read -r gitdir; do
    local repo="${gitdir%/}"
    repo="${repo%/.git}"
    (
      cd "$repo" || exit
      local status_lines="" tags="scanned"

      if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
        status_lines+="uncommitted changes"
        tags+=" dirty"
      fi

      if git rev-parse --symbolic-full-name '@{u}' &>/dev/null; then
        [[ "$do_fetch" -eq 1 ]] && timeout 10 git fetch --quiet 2>/dev/null

        local ahead behind
        ahead=$(git rev-list --count '@{u}..HEAD' 2>/dev/null)
        behind=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null)

        if [[ "$ahead" -gt 0 ]]; then
          [[ -n "$status_lines" ]] && status_lines+=", "
          status_lines+="$ahead commit(s) not pushed"
          tags+=" ahead"
        fi
        if [[ "$behind" -gt 0 ]]; then
          [[ -n "$status_lines" ]] && status_lines+=", "
          status_lines+="$behind commit(s) behind"
          tags+=" behind"
        fi
      else
        [[ -n "$status_lines" ]] && status_lines+=", "
        status_lines+="no upstream branch"
        tags+=" noupstream"
      fi

      echo "$tags|${repo/#$HOME/~}|$status_lines" >> "$results"
    ) &
    (( running++ ))
    if (( running >= max_jobs )); then
      wait
      running=0
    fi
  done
  wait

  local total=0 dirty=0 ahead_n=0 behind_n=0 noup=0
  local tags name status_lines found=0
  while IFS='|' read -r tags name status_lines; do
    (( total++ ))
    [[ "$tags" == *dirty* ]] && (( dirty++ ))
    [[ "$tags" == *ahead* ]] && (( ahead_n++ ))
    [[ "$tags" == *behind* ]] && (( behind_n++ ))
    [[ "$tags" == *noupstream* ]] && (( noup++ ))
    if [[ -n "$status_lines" ]]; then
      echo "$name: $status_lines"
      found=1
    fi
  done < "$results"
  rm -f "$results"

  if (( found == 0 )); then
    echo "no changes found in ${dir/#$HOME/~} ($total repos scanned)"
  fi

  if (( verbose )); then
    echo "scanned $total repos: $dirty dirty, $ahead_n ahead, $behind_n behind, $noup missing upstream"
  fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.local/bin:$HOME/.local/npm-global/bin:$PATH"

export PRISMLAUNCHER_DATA_DIR="$HOME/sync/minecraft"
