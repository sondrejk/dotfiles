# dotfiles

Personal configuration for Arch Linux, native and WSL: zsh, tmux, Neovim, kitty, WezTerm and AI agent setup.

## Install

Prerequisites:

- Arch Linux with `sudo` rights
- `git` and an internet connection

1. Clone the repo.

   ```bash
   git clone git@github.com:sondrejk/dotfiles.git ~/repos/personal/dotfiles
   ```

2. Run the install script and answer the prompts.

   ```bash
   bash ~/repos/personal/dotfiles/install-arch.sh
   ```

3. Open a new terminal.

Verification: `ls -l ~/.zshrc` points into the dotfiles repo, and the prompt uses powerlevel10k.

The script installs yay, oh-my-zsh, powerlevel10k, tpm and the package list, then symlinks every config into place.
It skips what is already installed, so it is safe to run again.
The `ln_link` block in `install-arch.sh` is the source of truth for symlinks.

`.gitconfig` is gitignored.
The script writes it from the name and email you type during install.

## AI setup

Agent configuration lives in `ai/`, provider-agnostic and shared between machines.
See [CLAUDE.md](CLAUDE.md) for the layout and the `ai-skills` commands.

## Manual extras

The install script does not handle these.
Install them when you need them.

| Package | Source | Needed for |
| --- | --- | --- |
| `vim-gruvbox-community` | AUR | The `colorscheme gruvbox` line in `.vimrc` |
| `drawio-desktop-bin` | AUR | The drawio skill in `ai/vendor/` |
| `gowall` | AUR | Recolouring the images in `wallpapers/` |
| `spotify` | AUR | Desktop client. The script installs `spotify-player`, the TUI |
| `xone-dkms` | extra | Xbox One controller |
| `riscv64-elf-gcc`, `riscv64-elf-binutils` | extra | xv6 and RISC-V. `qemu-full` from the script provides the emulator |

```bash
yay -S vim-gruvbox-community drawio-desktop-bin gowall spotify
```

```bash
sudo pacman -S xone-dkms riscv64-elf-gcc riscv64-elf-binutils
```

`pdf-flashcards` is a standalone script in this repo, not symlinked.
Run it from the repo. It needs `fzf`, `poppler` and the `copilot` CLI.

## Hide the systemd-boot menu

1. Open the loader configuration as root.

   ```bash
   sudo vim /boot/loader/loader.conf
   ```

2. Set the timeout to `menu-hidden`.

   ```ini
   timeout menu-hidden
   ```

Verification: the boot menu does not appear on the next boot.
Hold `Space` during boot to show it again.

## Troubleshooting

### Vim prints "E185: Cannot find color scheme 'gruvbox'"

**Cause:** the colorscheme that `.vimrc` selects is a separate package.

**Fix:** install it from the AUR.

```bash
yay -S vim-gruvbox-community
```

### Minecraft crashes on startup with an OpenAL error

**Cause:** OpenAL selects an audio driver that does not work with PipeWire.

**Fix:** force the PulseAudio driver in `~/.alsoftrc`.

```ini
[general]
drivers=pulse
hrtf=true
```
