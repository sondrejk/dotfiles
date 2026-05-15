#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FAILED_PACKAGES=()
FAILED_REASONS=()

confirm() {
  read -rp "$1 [y/N]: " ans
  case "$ans" in
  [Yy]*) return 0 ;;
  *) return 1 ;;
  esac
}

record_failure() {
  local pkg="$1"
  local reason="$2"

  FAILED_PACKAGES+=("$pkg")
  FAILED_REASONS+=("$reason")
}

install_yay() {
  echo "Installing base-devel and git (needed for building AUR packages)..."
  sudo pacman -S --needed --noconfirm base-devel git

  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"

  pushd "$tmpdir/yay" >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null

  rm -rf "$tmpdir"
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh already installed at $HOME/.oh-my-zsh"
    return 0
  fi

  echo "Cloning oh-my-zsh to $HOME/.oh-my-zsh (will not modify ~/.zshrc)..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  echo "Cloned oh-my-zsh."
}

install_powerlevel10k() {
  target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [ -d "$target" ]; then
    echo "powerlevel10k already present at $target"
    return 0
  fi

  echo "Cloning powerlevel10k to $target..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
  echo "Cloned powerlevel10k into $target."
}

install_tpm() {
  target="$HOME/.tmux/plugins/tpm"

  if [ -d "$target" ]; then
    echo "tpm already installed at $target"
    return 0
  fi

  echo "Cloning tpm to $target..."
  mkdir -p "$(dirname "$target")"
  git clone https://github.com/tmux-plugins/tpm "$target"
  echo "Cloned tpm into $target."
}

setup_gitconfig() {
  default_name="$(git config --global user.name 2>/dev/null || true)"
  default_email="$(git config --global user.email 2>/dev/null || true)"

  read -rp "Git user.name [${default_name}]: " git_name
  git_name="${git_name:-$default_name}"

  read -rp "Git user.email [${default_email}]: " git_email
  git_email="${git_email:-$default_email}"

  if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    echo "Name or email empty — skipping .gitconfig creation."
    return 0
  fi

  cfg_path="$DOTFILES_DIR/.gitconfig"

  if [ -f "$cfg_path" ]; then
    mv "$cfg_path" "$cfg_path.bak"
    echo "Backed up existing $cfg_path -> $cfg_path.bak"
  fi

  cat >"$cfg_path" <<EOF
[user]
name = $git_name
email = $git_email
[core]
editor = ${EDITOR:-vim}
EOF

  echo "Wrote $cfg_path"
}

install_package() {
  local pkg="$1"
  local log_file
  local rc

  log_file="$(mktemp)"

  echo
  echo "Installing package: $pkg"

  set +e
  sudo pacman -S --needed --noconfirm "$pkg" >"$log_file" 2>&1
  rc=$?
  set -e

  if [ "$rc" -eq 0 ]; then
    echo "Installed or already present: $pkg"
    rm -f "$log_file"
    return 0
  fi

  echo
  echo "Failed to install: $pkg"
  echo "pacman exited with code: $rc"
  echo
  echo "Error output:"
  sed 's/^/  /' "$log_file"

  reason="$(cat "$log_file")"
  record_failure "$pkg" "$reason"

  rm -f "$log_file"

  if confirm "Continue installing the remaining packages?"; then
    return 0
  else
    echo "Stopping package installation."
    return 1
  fi
}

install_packages() {
  local pkg

  for pkg in "$@"; do
    install_package "$pkg" || break
  done
}

print_summary() {
  echo
  echo "========================================"
  echo "Install summary"
  echo "========================================"

  if [ "${#FAILED_PACKAGES[@]}" -eq 0 ]; then
    echo "All selected packages were installed or already present."
    return 0
  fi

  echo "The following packages failed to install:"
  echo

  for i in "${!FAILED_PACKAGES[@]}"; do
    echo "----------------------------------------"
    echo "Package: ${FAILED_PACKAGES[$i]}"
    echo "Reason:"
    echo "${FAILED_REASONS[$i]}" | sed 's/^/  /'
    echo
  done

  echo "Total failed packages: ${#FAILED_PACKAGES[@]}"
}

packages_common=(
  git
  curl
  neovim
  zsh
  openssh
  zoxide
  bat
  fzf
  ripgrep
  docker
  docker-compose
  tmux
  fd
  poetry
  npm
  yarn
  pyenv
  lazygit
  lazydocker
  uv
  jq
  eza
  wget
  gvim
  github-cli
  pass
  pass-otp
  gpg
  pnpm
  tldr
  unzip
  xclip
  qemu-full
)

packages_wsl=(
  xdg-utils
  vulkan-dzn
)

packages_native=(
  ttf-jetbrains-mono-nerd
  xorg-server
  xorg-xinit
  xorg-apps
  mesa
  pipewire
  pipewire-pulse
  pipewire-alsa
  wireplumber
  networkmanager
  obsidian
  bitwarden
  steam
  btop
  firefox
  wezterm
  ffmpeg4.4
  zenity
  qemu-full
  tailscale
  gdb
  valgrind
)

echo "This script will install packages and symlink dotfiles from: $DOTFILES_DIR"

if confirm "Install yay (AUR helper)?"; then
  install_yay
fi

if confirm "Are you running this on WSL Arch?"; then
  is_wsl=true
else
  is_wsl=false
fi

if confirm "Install Oh My Zsh (clone only, will NOT overwrite ~/.zshrc)?"; then
  install_oh_my_zsh
fi

if confirm "Clone powerlevel10k into ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k?"; then
  install_powerlevel10k
fi

if confirm "Install tmux plugin manager (tpm)?"; then
  install_tpm
fi

if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
  echo ".gitconfig already exists at $DOTFILES_DIR/.gitconfig — skipping creation."
else
  if confirm "Create a .gitconfig in the dotfiles repo (prompt for name/email)?"; then
    setup_gitconfig
  fi
fi

if [ "$is_wsl" = true ]; then
  packages=("${packages_common[@]}" "${packages_wsl[@]}")
else
  packages=("${packages_common[@]}" "${packages_native[@]}")
fi

echo
echo "Updating package database..."
set +e
sudo pacman -Syu --noconfirm
rc_update=$?
set -e

if [ "$rc_update" -ne 0 ]; then
  echo
  echo "Warning: 'pacman -Syu' exited with code $rc_update."
  if ! confirm "Continue with package installation anyway?"; then
    print_summary
    exit 1
  fi
fi

echo
echo "Installing selected packages one by one..."
install_packages "${packages[@]}"

if [ "$is_wsl" = true ]; then
  target_dir="/mnt/c/Users/sondr/.config"

  if [ -d "$target_dir" ] || mkdir -p "$target_dir" 2>/dev/null; then
    echo "Copying wezterm config to $target_dir"
    cp -a "$DOTFILES_DIR/wezterm" "$target_dir/" || echo "Failed to copy wezterm — check permissions or path"
  else
    echo "WSL target $target_dir not found and could not be created — skipping wezterm copy"
  fi
fi

echo
echo "About to symlink selected dotfiles from $DOTFILES_DIR into your home directory."

if confirm "Proceed with symlinking dotfiles (existing files will be backed up with .bak)?"; then
  ln_link() {
    src="$1"
    dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      mv "$dest" "$dest.bak"
      echo "Backed up $dest -> $dest.bak"
    fi

    ln -sfn "$src" "$dest"
    echo "Linked $dest -> $src"
  }

  if [ -d "$DOTFILES_DIR/nvim" ]; then
    ln_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  fi

  if [ -d "$DOTFILES_DIR/wezterm" ]; then
    if [ "${is_wsl:-false}" = true ]; then
      echo "Skipping wezterm symlink on WSL because it was copied earlier."
    else
      ln_link "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"
    fi
  fi

  if [ -d "$DOTFILES_DIR/tmuxinator" ]; then
    ln_link "$DOTFILES_DIR/tmuxinator" "$HOME/.config/tmuxinator"
  fi

  if [ -d "$DOTFILES_DIR/fastfetch" ]; then
    ln_link "$DOTFILES_DIR/fastfetch" "$HOME/.config/fastfetch"
  fi

  if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    ln_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  fi

  if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    ln_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  fi
fi

print_summary

echo
echo "Install script finished. Review backups (*.bak) if any were created."
