#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v pacman &>/dev/null; then
	echo "This script requires pacman (Arch Linux or an Arch-based distro) — aborting." >&2
	exit 1
fi

ASSUME_YES=false
for arg in "$@"; do
	case "$arg" in
	-y | --yes) ASSUME_YES=true ;;
	esac
done

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

LOG_FILE="/tmp/install-arch-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Logging full output to $LOG_FILE"

FAILED_PACKAGES=()
FAILED_REASONS=()

confirm() {
	if [ "$ASSUME_YES" = true ]; then
		echo "$1 [y/N]: y (auto-confirmed, --yes)"
		return 0
	fi

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
	if command -v yay &>/dev/null || command -v paru &>/dev/null; then
		echo "AUR helper already installed ($(command -v yay || command -v paru)) — skipping."
		return 0
	fi

	echo "Installing base-devel and git (needed for building AUR packages)..."
	sudo pacman -S --needed --noconfirm base-devel git

	local tmpdir
	tmpdir=$(mktemp -d)
	trap 'rm -rf "$tmpdir"' EXIT

	git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"

	pushd "$tmpdir/yay" >/dev/null
	makepkg -si --noconfirm
	popd >/dev/null

	rm -rf "$tmpdir"
	trap - EXIT
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
	local target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

	if [ -d "$target" ]; then
		echo "powerlevel10k already present at $target"
		return 0
	fi

	echo "Cloning powerlevel10k to $target..."
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
	echo "Cloned powerlevel10k into $target."
}

install_tpm() {
	local target="$HOME/.tmux/plugins/tpm"

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
	local default_name default_email git_name git_email cfg_path backup_path

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
		backup_path="$cfg_path.bak.$(date +%Y%m%d-%H%M%S)"
		mv "$cfg_path" "$backup_path"
		echo "Backed up existing $cfg_path -> $backup_path"
	fi

	cat >"$cfg_path" <<EOF
[user]
name = $git_name
email = $git_email
[core]
editor = ${EDITOR:-vim}
pager = delta
[interactive]
diffFilter = delta --color-only
[delta]
navigate = true
side-by-side = true
line-numbers = true
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

	echo "Continuing with the remaining packages — see the summary at the end for all failures."
	return 0
}

install_packages() {
	local pkg

	# install_package always returns 0 and records failures itself, so every
	# package is attempted regardless of earlier ones failing.
	for pkg in "$@"; do
		install_package "$pkg"
	done
}

resolve_vim_gvim_conflict() {
	# gvim conflicts with vim (both provide vim-minimal). Some Arch derivatives
	# (e.g. CachyOS's zsh config) depend on the "vim" package name, but gvim
	# Provides=vim, so removing vim first and letting gvim install right after
	# keeps that dependency satisfied throughout.
	# -dd skips dependency checks in both directions, which is safe only
	# because gvim reinstates the "vim" name immediately afterwards.
	if pacman -Qi vim &>/dev/null && ! pacman -Qi gvim &>/dev/null; then
		echo "Removing 'vim' so 'gvim' (built with clipboard/GUI support) can replace it..."
		sudo pacman -Rdd --noconfirm vim
	fi
}

install_aur_extras() {
	local helper
	helper="$(command -v yay || command -v paru || true)"

	if [ -z "$helper" ]; then
		echo "No AUR helper (yay/paru) installed — skipping AUR-only package: lazysql"
		return 0
	fi

	echo "Installing lazysql via $helper (AUR)..."
	if ! "$helper" -S --needed --noconfirm lazysql; then
		echo "Failed to install lazysql via $helper."
		record_failure "lazysql" "$helper -S --needed --noconfirm lazysql failed"
	fi
}

install_uv_tools() {
	if ! command -v uv &>/dev/null; then
		echo "uv not installed — skipping uv-based tool: posting"
		return 0
	fi

	echo "Installing posting via 'uv tool install'..."
	if ! uv tool install posting; then
		echo "Failed to install posting via uv."
		record_failure "posting" "uv tool install posting failed"
	fi
}

setup_docker() {
	if ! command -v docker &>/dev/null; then
		return 0
	fi

	echo "Enabling and starting the docker service..."
	sudo systemctl enable --now docker

	if ! groups "$USER" | grep -qw docker; then
		echo "Adding $USER to the docker group (log out and back in, or run 'newgrp docker', for this to take effect)..."
		sudo usermod -aG docker "$USER"
	fi
}

set_default_shell() {
	local zsh_path current_shell

	zsh_path="$(command -v zsh)"
	if [ -z "$zsh_path" ]; then
		echo "zsh not found on PATH — skipping default shell change."
		return 0
	fi

	current_shell="$(getent passwd "$USER" | cut -d: -f7)"
	if [ "$current_shell" = "$zsh_path" ]; then
		echo "Default shell is already $zsh_path — skipping."
		return 0
	fi

	echo "Changing default shell to $zsh_path (log out and back in, or restart your terminal, for it to take effect)..."
	if ! chsh -s "$zsh_path" "$USER"; then
		echo "Failed to change default shell automatically — run 'chsh -s $zsh_path' manually."
	fi
}

setup_kitty_theme() {
	local theme_conf="$CONFIG_HOME/kitty/current-theme.conf"

	if [ -f "$theme_conf" ] || ! command -v kitty &>/dev/null; then
		return 0
	fi

	echo "Applying Gruvbox Dark kitty theme..."
	kitty +kitten themes --reload-in=none "Gruvbox Dark" || echo "Failed to apply kitty theme automatically — run 'kitty +kitten themes' manually."
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
	docker-buildx
	tmux
	tmuxp
	fd
	poetry
	npm
	yarn
	base-devel
	openssl
	xz
	tk
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
	gnupg
	pnpm
	unzip
	xclip
	qemu-full
	fastfetch
	ncdu
	duf
	hyperfine
	gping
	direnv
	just
	entr
	atuin
	git-delta
	glow
	fx
	yazi
	tokei
	procs
	sd
	lnav
	httpie
	doggo
	rclone
	jc
	k9s
	spotify-player
	wl-clip-persist
	pandoc-cli
	texlive-latexextra
	typst
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
	discord
	godot
	prismlauncher
	btop
	firefox
	kitty
	zathura
	zathura-pdf-mupdf
	ffmpeg4.4
	zenity
	tailscale
	gdb
	valgrind
)

echo "This script will install packages and symlink dotfiles from: $DOTFILES_DIR"

if confirm "Install yay (AUR helper)?"; then
	install_yay
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

packages=("${packages_common[@]}" "${packages_native[@]}")

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

resolve_vim_gvim_conflict

echo
echo "Installing selected packages one by one..."
install_packages "${packages[@]}"

install_aur_extras
install_uv_tools
setup_docker

if confirm "Set zsh as your default login shell (chsh)?"; then
	set_default_shell
fi

echo
echo "About to symlink selected dotfiles from $DOTFILES_DIR into your home directory."

if confirm "Proceed with symlinking dotfiles (existing files will be backed up with a timestamped .bak)?"; then
	ln_link() {
		local src="$1"
		local dest="$2"
		local backup_dest

		mkdir -p "$(dirname "$dest")"

		if [ -e "$dest" ] || [ -L "$dest" ]; then
			if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
				: # already linked correctly, nothing to back up
			else
				backup_dest="$dest.bak.$(date +%Y%m%d-%H%M%S)"
				mv "$dest" "$backup_dest"
				echo "Backed up $dest -> $backup_dest"
			fi
		fi

		ln -sfn "$src" "$dest"
		echo "Linked $dest -> $src"
	}

	if [ -d "$DOTFILES_DIR/nvim" ]; then
		ln_link "$DOTFILES_DIR/nvim" "$CONFIG_HOME/nvim"
	fi

	if [ -d "$DOTFILES_DIR/kitty" ]; then
		ln_link "$DOTFILES_DIR/kitty" "$CONFIG_HOME/kitty"
		setup_kitty_theme
	fi

	if [ -d "$DOTFILES_DIR/zathura" ]; then
		ln_link "$DOTFILES_DIR/zathura" "$CONFIG_HOME/zathura"
	fi

	if [ -d "$DOTFILES_DIR/tmuxp" ]; then
		ln_link "$DOTFILES_DIR/tmuxp" "$CONFIG_HOME/tmuxp"
	fi

	if [ -d "$DOTFILES_DIR/fastfetch" ]; then
		ln_link "$DOTFILES_DIR/fastfetch" "$CONFIG_HOME/fastfetch"
	fi

	if [ -f "$DOTFILES_DIR/.zshrc" ]; then
		ln_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
	fi

	if [ -f "$DOTFILES_DIR/.tmux.conf" ]; then
		ln_link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
	fi

	if [ -f "$DOTFILES_DIR/.vimrc" ]; then
		ln_link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
	fi

	if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
		ln_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
	fi

	# AI setup: instructions file, skills sync and hooks.
	# ai/AGENTS.md is provider-agnostic; Claude Code only reads CLAUDE.md,
	# so it gets symlinked into place.
	if [ -d "$DOTFILES_DIR/ai" ]; then
		if [ -f "$DOTFILES_DIR/ai/AGENTS.md" ]; then
			ln_link "$DOTFILES_DIR/ai/AGENTS.md" "$HOME/.claude/CLAUDE.md"
		fi

		if [ -x "$DOTFILES_DIR/ai/bin/ai-skills" ]; then
			ln_link "$DOTFILES_DIR/ai/bin/ai-skills" "$HOME/.local/bin/ai-skills"

			echo "Syncing AI skills into provider directories"
			"$DOTFILES_DIR/ai/bin/ai-skills" sync ||
				echo "ai-skills sync failed — run it by hand to see why"
		fi
	fi
fi

print_summary

echo
echo "Install script finished. Review backups (*.bak.*) if any were created."
echo "Full log written to $LOG_FILE"
