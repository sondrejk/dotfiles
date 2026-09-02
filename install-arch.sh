#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STAGE_ORDER=(aur zsh p10k tpm gitconfig packages shell symlink)

print_usage() {
	cat <<EOF
Usage: install-arch.sh [OPTIONS]

Options:
  -y, --yes             Auto-confirm every prompt (unattended run)
  -h, --help            Show this help and exit
  --dry-run             Print what would happen without changing anything
  --only=STAGE          Only run one stage: ${STAGE_ORDER[*]}
  --skip=STAGE          Skip one stage: ${STAGE_ORDER[*]}
  --verify              Check symlinks/tools/shell against expectations, then exit
  --prune-backups[=N]   List (and offer to delete) *.bak.* files older than N
                         days (default 30), then exit

Machine-local extras: add package names (one per line, # for comments) to
packages.local.txt in the repo root; they are appended to the install list
and gitignored.
EOF
}

ASSUME_YES=false
DRY_RUN=false
ONLY_STAGE=""
SKIP_STAGE=""
MODE="install"
PRUNE_DAYS=30

for arg in "$@"; do
	case "$arg" in
	-y | --yes) ASSUME_YES=true ;;
	-h | --help)
		print_usage
		exit 0
		;;
	--dry-run) DRY_RUN=true ;;
	--only=*) ONLY_STAGE="${arg#--only=}" ;;
	--skip=*) SKIP_STAGE="${arg#--skip=}" ;;
	--verify) MODE="verify" ;;
	--prune-backups) MODE="prune-backups" ;;
	--prune-backups=*)
		MODE="prune-backups"
		PRUNE_DAYS="${arg#--prune-backups=}"
		;;
	*)
		echo "Unknown option: $arg" >&2
		print_usage >&2
		exit 1
		;;
	esac
done

if ! command -v pacman &>/dev/null; then
	echo "This script requires pacman (Arch Linux or an Arch-based distro) — aborting." >&2
	exit 1
fi

valid_stage() {
	local want="$1" s
	for s in "${STAGE_ORDER[@]}"; do
		[ "$s" = "$want" ] && return 0
	done
	return 1
}

if [ -n "$ONLY_STAGE" ] && ! valid_stage "$ONLY_STAGE"; then
	echo "Unknown --only stage: $ONLY_STAGE (expected one of: ${STAGE_ORDER[*]})" >&2
	exit 1
fi

if [ -n "$SKIP_STAGE" ] && ! valid_stage "$SKIP_STAGE"; then
	echo "Unknown --skip stage: $SKIP_STAGE (expected one of: ${STAGE_ORDER[*]})" >&2
	exit 1
fi

if [ -z "${NO_COLOR:-}" ] && [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
	COLOR_RESET="$(tput sgr0)"
	COLOR_INFO="$(tput setaf 4)"
	COLOR_WARN="$(tput setaf 3)"
	COLOR_ERROR="$(tput setaf 1)"
else
	COLOR_RESET=""
	COLOR_INFO=""
	COLOR_WARN=""
	COLOR_ERROR=""
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

LOG_FILE="/tmp/install-arch-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Logging full output to $LOG_FILE"
if [ "$DRY_RUN" = true ]; then
	echo "Dry run: no packages will be installed and no files will be changed."
fi

FAILED_PACKAGES=()
FAILED_REASONS=()
LINKED_COUNT=0
BACKED_UP_COUNT=0
SKIPPED_COUNT=0

log_info() { echo "${COLOR_INFO}info:${COLOR_RESET} $*"; }
log_warn() { echo "${COLOR_WARN}warn:${COLOR_RESET} $*" >&2; }
log_error() { echo "${COLOR_ERROR}error:${COLOR_RESET} $*" >&2; }

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

should_run_stage() {
	local stage="$1"

	if [ -n "$ONLY_STAGE" ] && [ "$stage" != "$ONLY_STAGE" ]; then
		return 1
	fi

	if [ -n "$SKIP_STAGE" ] && [ "$stage" = "$SKIP_STAGE" ]; then
		return 1
	fi

	return 0
}

record_failure() {
	local pkg="$1"
	local reason="$2"

	FAILED_PACKAGES+=("$pkg")
	FAILED_REASONS+=("$reason")
}

check_connectivity() {
	if [ "$DRY_RUN" = true ]; then
		return 0
	fi

	if ! command -v curl &>/dev/null; then
		echo "curl not found — skipping connectivity check."
		return 0
	fi

	echo "Checking internet connectivity..."
	if curl -fsS --max-time 5 -o /dev/null https://geo.mirror.pkgbuild.com ||
		curl -fsS --max-time 5 -o /dev/null https://archlinux.org; then
		echo "Connectivity OK."
		return 0
	fi

	log_error "No internet connectivity detected (tried archlinux.org) — check your network and try again."
	exit 1
}

install_yay() {
	if command -v yay &>/dev/null || command -v paru &>/dev/null; then
		echo "AUR helper already installed ($(command -v yay || command -v paru)) — skipping."
		return 0
	fi

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would install base-devel, git, and build yay from the AUR"
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

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would clone oh-my-zsh to $HOME/.oh-my-zsh"
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

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would clone powerlevel10k to $target"
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

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would clone tpm to $target"
		return 0
	fi

	echo "Cloning tpm to $target..."
	mkdir -p "$(dirname "$target")"
	git clone https://github.com/tmux-plugins/tpm "$target"
	echo "Cloned tpm into $target."
}

setup_gitconfig() {
	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would prompt for git user.name/email and write $DOTFILES_DIR/.gitconfig"
		return 0
	fi

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
	local index="$2"
	local total="$3"
	local log_file
	local rc
	local reason

	echo
	echo "[$index/$total] Installing package: $pkg"

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would run: pacman -S --needed --noconfirm $pkg"
		return 0
	fi

	log_file="$(mktemp)"

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
	log_error "Failed to install: $pkg (pacman exited with code $rc)"
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
	local total=$#
	local i=0

	# install_package always returns 0 and records failures itself, so every
	# package is attempted regardless of earlier ones failing.
	for pkg in "$@"; do
		i=$((i + 1))
		install_package "$pkg" "$i" "$total"
	done
}

retry_failed_packages() {
	if [ "${#FAILED_PACKAGES[@]}" -eq 0 ] || [ "$DRY_RUN" = true ]; then
		return 0
	fi

	if ! confirm "Retry the ${#FAILED_PACKAGES[@]} failed package(s)?"; then
		return 0
	fi

	local retry_list=("${FAILED_PACKAGES[@]}")
	FAILED_PACKAGES=()
	FAILED_REASONS=()
	install_packages "${retry_list[@]}"
}

resolve_vim_gvim_conflict() {
	# gvim conflicts with vim (both provide vim-minimal). Some Arch derivatives
	# (e.g. CachyOS's zsh config) depend on the "vim" package name, but gvim
	# Provides=vim, so removing vim first and letting gvim install right after
	# keeps that dependency satisfied throughout.
	# -dd skips dependency checks in both directions, which is safe only
	# because gvim reinstates the "vim" name immediately afterwards.
	if pacman -Qi vim &>/dev/null && ! pacman -Qi gvim &>/dev/null; then
		if [ "$DRY_RUN" = true ]; then
			log_info "[dry-run] would remove 'vim' so 'gvim' can replace it"
			return 0
		fi
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

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would run: $helper -S --needed --noconfirm lazysql"
		return 0
	fi

	echo "Installing lazysql via $helper (AUR)..."
	if ! "$helper" -S --needed --noconfirm lazysql; then
		log_error "Failed to install lazysql via $helper."
		record_failure "lazysql" "$helper -S --needed --noconfirm lazysql failed"
	fi
}

install_uv_tools() {
	if ! command -v uv &>/dev/null; then
		echo "uv not installed — skipping uv-based tool: posting"
		return 0
	fi

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would run: uv tool install posting"
		return 0
	fi

	echo "Installing posting via 'uv tool install'..."
	if ! uv tool install posting; then
		log_error "Failed to install posting via uv."
		record_failure "posting" "uv tool install posting failed"
	fi
}

setup_docker() {
	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would enable+start the docker service and add \$USER to the docker group (if not already)"
		return 0
	fi

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
	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would set zsh as the default login shell (chsh) if it isn't already"
		return 0
	fi

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
		log_warn "Failed to change default shell automatically — run 'chsh -s $zsh_path' manually."
	fi
}

setup_kitty_theme() {
	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would apply the Gruvbox Dark kitty theme (if not already configured)"
		return 0
	fi

	local theme_conf="$CONFIG_HOME/kitty/current-theme.conf"

	if [ -f "$theme_conf" ] || ! command -v kitty &>/dev/null; then
		return 0
	fi

	echo "Applying Gruvbox Dark kitty theme..."
	kitty +kitten themes --reload-in=none "Gruvbox Dark" || log_warn "Failed to apply kitty theme automatically — run 'kitty +kitten themes' manually."
}

ln_link() {
	local src="$1"
	local dest="$2"
	local backup_dest

	if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
		SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
		return 0
	fi

	if [ "$DRY_RUN" = true ]; then
		if [ -e "$dest" ] || [ -L "$dest" ]; then
			log_info "[dry-run] would back up $dest, then link it -> $src"
			BACKED_UP_COUNT=$((BACKED_UP_COUNT + 1))
		else
			log_info "[dry-run] would link $dest -> $src"
		fi
		LINKED_COUNT=$((LINKED_COUNT + 1))
		return 0
	fi

	mkdir -p "$(dirname "$dest")"

	if [ -e "$dest" ] || [ -L "$dest" ]; then
		backup_dest="$dest.bak.$(date +%Y%m%d-%H%M%S)"
		mv "$dest" "$backup_dest"
		echo "Backed up $dest -> $backup_dest"
		BACKED_UP_COUNT=$((BACKED_UP_COUNT + 1))
	fi

	ln -sfn "$src" "$dest"
	LINKED_COUNT=$((LINKED_COUNT + 1))
	echo "Linked $dest -> $src"
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

print_symlink_summary() {
	echo
	echo "Symlink summary: linked $LINKED_COUNT, backed up $BACKED_UP_COUNT, already correct (skipped) $SKIPPED_COUNT"
}

verify_installation() {
	local ok=true
	local dest want pkg bin

	echo "Checking symlinks..."
	local -A expected_links=(
		["$CONFIG_HOME/nvim"]="$DOTFILES_DIR/nvim"
		["$CONFIG_HOME/kitty"]="$DOTFILES_DIR/kitty"
		["$CONFIG_HOME/zathura"]="$DOTFILES_DIR/zathura"
		["$CONFIG_HOME/tmuxp"]="$DOTFILES_DIR/tmuxp"
		["$CONFIG_HOME/fastfetch"]="$DOTFILES_DIR/fastfetch"
		["$HOME/.zshrc"]="$DOTFILES_DIR/.zshrc"
		["$HOME/.tmux.conf"]="$DOTFILES_DIR/.tmux.conf"
		["$HOME/.vimrc"]="$DOTFILES_DIR/.vimrc"
		["$HOME/.gitconfig"]="$DOTFILES_DIR/.gitconfig"
		["$HOME/.claude/CLAUDE.md"]="$DOTFILES_DIR/ai/AGENTS.md"
		["$HOME/.local/bin/ai-skills"]="$DOTFILES_DIR/ai/bin/ai-skills"
	)

	for dest in "${!expected_links[@]}"; do
		want="${expected_links[$dest]}"

		if [ ! -e "$want" ]; then
			continue # not part of this checkout
		fi

		if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$want" ]; then
			echo "  OK    $dest -> $want"
		else
			echo "  FAIL  $dest (expected symlink -> $want)"
			ok=false
		fi
	done

	echo
	echo "Checking default shell..."
	local zsh_path current_shell
	zsh_path="$(command -v zsh || true)"
	current_shell="$(getent passwd "$USER" | cut -d: -f7)"
	if [ -n "$zsh_path" ] && [ "$current_shell" = "$zsh_path" ]; then
		echo "  OK    default shell is zsh"
	else
		echo "  FAIL  default shell is '$current_shell', expected '$zsh_path'"
		ok=false
	fi

	echo
	echo "Checking core tools on PATH..."
	local -A expected_bins=(
		[git]=git [zsh]=zsh [tmux]=tmux [neovim]=nvim [fzf]=fzf
		[ripgrep]=rg [bat]=bat [fd]=fd [jq]=jq [eza]=eza
		[lazygit]=lazygit [lazydocker]=lazydocker [docker]=docker
		[kitty]=kitty [zathura]=zathura
	)
	for pkg in "${!expected_bins[@]}"; do
		bin="${expected_bins[$pkg]}"
		if command -v "$bin" &>/dev/null; then
			echo "  OK    $bin ($pkg)"
		else
			echo "  FAIL  $bin ($pkg) not found on PATH"
			ok=false
		fi
	done

	echo
	if [ "$ok" = true ]; then
		echo "Verification passed."
		return 0
	fi

	echo "Verification found issues — see FAIL lines above."
	return 1
}

prune_backups() {
	local cutoff_days="$1"
	local -a search_dirs=("$HOME" "$CONFIG_HOME" "$HOME/.claude" "$HOME/.local/bin")
	local -a found=()
	local f

	while IFS= read -r -d '' f; do
		found+=("$f")
	done < <(find "${search_dirs[@]}" -maxdepth 1 -name '*.bak.*' -mtime "+$cutoff_days" -print0 2>/dev/null)

	if [ "${#found[@]}" -eq 0 ]; then
		echo "No backup files older than $cutoff_days day(s) found."
		return 0
	fi

	echo "Backup files older than $cutoff_days day(s):"
	printf '  %s\n' "${found[@]}"
	echo
	echo "Total: ${#found[@]} file(s)."

	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would prompt to delete these"
		return 0
	fi

	if confirm "Delete these ${#found[@]} backup file(s)?"; then
		local rc=0
		for f in "${found[@]}"; do
			rm -rf -- "$f" || rc=1
		done
		if [ "$rc" -eq 0 ]; then
			echo "Deleted ${#found[@]} backup file(s)."
		else
			log_warn "Some backups could not be deleted — check permissions."
		fi
	else
		echo "Left backups in place."
	fi
}

if [ "$MODE" = "verify" ]; then
	verify_installation
	exit $?
fi

if [ "$MODE" = "prune-backups" ]; then
	prune_backups "$PRUNE_DAYS"
	exit 0
fi

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

check_connectivity

if should_run_stage aur && confirm "Install yay/paru (AUR helper)?"; then
	install_yay
fi

if should_run_stage zsh && confirm "Install Oh My Zsh (clone only, will NOT overwrite ~/.zshrc)?"; then
	install_oh_my_zsh
fi

if should_run_stage p10k && confirm "Clone powerlevel10k into ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k?"; then
	install_powerlevel10k
fi

if should_run_stage tpm && confirm "Install tmux plugin manager (tpm)?"; then
	install_tpm
fi

if should_run_stage gitconfig; then
	if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
		echo ".gitconfig already exists at $DOTFILES_DIR/.gitconfig — skipping creation."
	else
		if confirm "Create a .gitconfig in the dotfiles repo (prompt for name/email)?"; then
			setup_gitconfig
		fi
	fi
fi

if should_run_stage packages; then
	packages=("${packages_common[@]}" "${packages_native[@]}")

	if [ -f "$DOTFILES_DIR/packages.local.txt" ]; then
		echo "Adding machine-local extra packages from packages.local.txt"
		while IFS= read -r line || [ -n "$line" ]; do
			line="${line%$'\r'}"
			line="${line#"${line%%[![:space:]]*}"}" # ltrim
			line="${line%"${line##*[![:space:]]}"}" # rtrim
			[ -z "$line" ] && continue
			[[ "$line" == \#* ]] && continue
			packages+=("$line")
		done <"$DOTFILES_DIR/packages.local.txt"
	fi

	echo
	echo "Updating package database..."
	if [ "$DRY_RUN" = true ]; then
		log_info "[dry-run] would run: pacman -Syu"
	else
		set +e
		sudo pacman -Syu --noconfirm
		rc_update=$?
		set -e

		if [ "$rc_update" -ne 0 ]; then
			echo
			log_warn "'pacman -Syu' exited with code $rc_update."
			if ! confirm "Continue with package installation anyway?"; then
				print_summary
				exit 1
			fi
		fi
	fi

	resolve_vim_gvim_conflict

	echo
	echo "Installing selected packages one by one..."
	install_packages "${packages[@]}"
	retry_failed_packages

	install_aur_extras
	install_uv_tools
	setup_docker
fi

if should_run_stage shell && confirm "Set zsh as your default login shell (chsh)?"; then
	set_default_shell
fi

echo
echo "About to symlink selected dotfiles from $DOTFILES_DIR into your home directory."

if should_run_stage symlink && confirm "Proceed with symlinking dotfiles (existing files will be backed up with a timestamped .bak)?"; then
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

			if [ "$DRY_RUN" = true ]; then
				log_info "[dry-run] would run: ai-skills sync"
			else
				echo "Syncing AI skills into provider directories"
				"$DOTFILES_DIR/ai/bin/ai-skills" sync ||
					log_warn "ai-skills sync failed — run it by hand to see why"
			fi
		fi
	fi

	print_symlink_summary
fi

print_summary

echo
echo "Install script finished. Review backups (*.bak.*) if any were created."
echo "Full log written to $LOG_FILE"
