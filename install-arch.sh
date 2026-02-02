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

# Optionally install Oh My Zsh (clone only — will NOT overwrite your ~/.zshrc)
install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh already installed at $HOME/.oh-my-zsh"
    return 0
  fi
  echo "Cloning oh-my-zsh to $HOME/.oh-my-zsh (will not modify ~/.zshrc)..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  echo "Cloned oh-my-zsh. Add 'export ZSH=\"$HOME/.oh-my-zsh\"' and 'source \$ZSH/oh-my-zsh.sh' to your ~/.zshrc if desired."
}

# Optionally install Powerlevel10k theme into the dotfiles repo
install_powerlevel10k() {
  target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ -d "$target" ]; then
    echo "powerlevel10k already present at $target"
    return 0
  fi
  echo "Cloning powerlevel10k to $target..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
  echo "Cloned powerlevel10k into $target. Your ~/.zshrc is unchanged and can source the theme from this location."
}

# Optionally install tmux plugin manager (tpm)
install_tpm() {
  target="$HOME/.tmux/plugins/tpm"
  if [ -d "$target" ]; then
    echo "tpm already installed at $target"
    return 0
  fi
  echo "Cloning tpm to $target..."
  mkdir -p "$(dirname "$target")"
  git clone https://github.com/tmux-plugins/tpm "$target"
  echo "Cloned tpm into $target. To enable plugins run: ~/.tmux/plugins/tpm/tpm install after starting tmux."
}

# Prompt for git user config and create .gitconfig in the dotfiles repo
setup_gitconfig() {
  # Try to read existing global values as defaults
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
    mv "$cfg_path" "$cfg_path".bak
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

packages_common=(git curl neovim zsh openssh zoxide bat fzf ripgrep docker docker-compose tmux fd poetry npm yarn pyenv lazygit lazydocker uv jq eza wget gvim github-cli pass pass-otp gpg pnpm tldr unzip xclip qemu-full)
packages_wsl=(xdg-utils vulkan-dzn)
packages_native=(ttf-jetbrains-mono-nerd xorg-server xorg-xinit xorg-apps mesa pulseaudio networkmanager obsidian bitwarden steam btop firefox wezterm ffmpeg4.4 zenity qemu-full tailscale gdb valgrind)

echo "This script will install packages and symlink dotfiles from: $DOTFILES_DIR"

if confirm "Install yay (AUR helper)?"; then
  install_yay
fi

if confirm "Are you running this on WSL Arch?"; then
  is_wsl=true
else
  is_wsl=false
fi

# Ask about optional shell/theme installs
if confirm "Install Oh My Zsh (clone only, will NOT overwrite ~/.zshrc)?"; then
  install_oh_my_zsh
fi

if confirm "Clone powerlevel10k into dotfiles repo ("${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"/powerlevel10k)?"; then
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
