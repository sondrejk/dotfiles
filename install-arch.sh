#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

confirm() {
  read -rp "$1 [y/N]: " ans
  case "$ans" in
    [Yy]*) return 0 ;;
    *) return 1 ;;
  esac
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

packages_common=(git curl neovim zsh openssh zoxide bat fzf ripgrep docker docker-compose tmux fd poetry npm yarn pyenv lazygit laztydocker uv jq eza wget gvim github-cli pass pass-otp gpg pnpm tldr unzip xclip qemu-full)
packages_wsl=(xdg-utils vulkan-dzn)
packages_native=(xorg-server xorg-xinit xorg-apps mesa pulseaudio networkmanager obsidian bitwarden steam btop firefox wezterm ffmpeg4.4 zenity qemu-full tailscale gdb valgrind)

echo "This script will install packages and symlink dotfiles from: $DOTFILES_DIR"

if confirm "Install yay (AUR helper)?"; then
  install_yay
fi

if confirm "Are you running this on WSL Arch?"; then
  is_wsl=true
else
  is_wsl=false
fi

if [ "$is_wsl" = true ]; then
  packages=("${packages_common[@]}" "${packages_wsl[@]}")
else
  packages=("${packages_common[@]}" "${packages_native[@]}")
fi

echo "Updating package database and installing packages..."
# Temporarily allow commands to fail so we still proceed to config steps
set +e
sudo pacman -Syu --noconfirm
rc_update=$?
if [ $rc_update -ne 0 ]; then
  echo "Warning: 'pacman -Syu' exited with code $rc_update — continuing"
fi

if [ ${#packages[@]} -gt 0 ]; then
  sudo pacman -S --needed --noconfirm "${packages[@]}"
  rc_install=$?
  if [ $rc_install -ne 0 ]; then
    echo "Warning: 'pacman -S' exited with code $rc_install — continuing"
  fi
else
  echo "No packages to install."
fi
set -e

if [ "$is_wsl" = true ]; then
  target_dir="/mnt/c/Users/sondr/.config"
  if [ -d "$target_dir" ] || mkdir -p "$target_dir" 2>/dev/null; then
    echo "Copying wezterm config to $target_dir"
    cp -a "$DOTFILES_DIR/wezterm" "$target_dir/" || echo "Failed to copy wezterm — check permissions or path"
  else
    echo "WSL target $target_dir not found and could not be created — skipping wezterm copy"
  fi
fi

echo "About to symlink selected dotfiles from $DOTFILES_DIR into your home directory."
if confirm "Proceed with symlinking dotfiles (existing files will be backed up with .bak)?"; then
  ln_link() {
    src="$1"
    dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      mv "$dest" "$dest".bak
      echo "Backed up $dest -> $dest.bak"
    fi
    ln -sfn "$src" "$dest"
    echo "Linked $dest -> $src"
  }

  # Common mappings (edit these to match your repo layout)
  if [ -d "$DOTFILES_DIR/nvim" ]; then
    ln_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  fi
  if [ -d "$DOTFILES_DIR/wezterm" ]; then
    if [ "${is_wsl:-false}" = true ]; then
      echo "Skipping wezterm symlink on WSL (copied earlier)."
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

  # Optional dotfiles in repo root
  if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    ln_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  fi
  if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    ln_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  fi
fi

echo "Install script finished. Review backups (*.bak) if any were created."
