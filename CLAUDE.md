# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for an Arch Linux setup (native and WSL). Config files are managed directly in this repo and symlinked into place by `install-arch.sh`.

## Setup / install

Run the interactive install script on a fresh Arch system:

```bash
bash install-arch.sh
```

It handles: yay (AUR), oh-my-zsh, powerlevel10k, tpm (tmux plugin manager), optional .gitconfig creation, package installation, and symlinking configs.

To manually re-symlink without reinstalling packages, find the `ln_link` block in `install-arch.sh` and run those `ln -sfn` commands by hand.

## Symlink targets

| Repo path | Symlinked to |
|---|---|
| `nvim/` | `~/.config/nvim` |
| `kitty/` | `~/.config/kitty` (native only — kitty is not used on WSL) |
| `wezterm/` | WSL only — copied to `/mnt/c/Users/sondr/.config/wezterm` by the install script |
| `tmuxp/` | `~/.config/tmuxp` |
| `fastfetch/` | `~/.config/fastfetch` |
| `.zshrc` | `~/.zshrc` |
| `.gitconfig` | `~/.gitconfig` |

`.tmux.conf` and `.vimrc` are not symlinked by the script — copy or symlink them manually if needed.

## Neovim

Built on [LazyVim](https://lazyvim.org). The entry point is `nvim/init.lua` → `nvim/lua/config/lazy.lua`.

- **Add plugins**: create a new file under `nvim/lua/plugins/` returning a lazy.nvim spec table.
- **Keymaps**: `nvim/lua/config/keymaps.lua` — `<C-hjkl>` are bound to nvim-tmux-navigation so pane navigation works across tmux splits.
- **Options**: `nvim/lua/config/options.lua`
- **Colorscheme**: gruvbox (`nvim/lua/plugins/gruvbox.lua`)
- **Copilot**: Tab is unmapped; use `<S-Tab>` to accept suggestions. `<leader>ai` dismisses the current suggestion.
- `nvim/lua/plugins/example.lua` is a LazyVim template — the `if true then return {} end` guard at the top keeps it inert.

Lock file (`nvim/lazy-lock.json`) is committed so plugin versions are reproducible. Run `:Lazy update` inside Neovim to update plugins and commit the updated lock file.

## tmux

Prefix is `C-a`. Key bindings:
- `|` / `-` — split horizontally / vertically (preserves cwd)
- `v` — enter copy mode; `v` to start selection, `y` to yank
- `r` — reload `~/.tmux.conf`
- `<C-hjkl>` — navigate panes (shared with nvim via christoomey/vim-tmux-navigator)

Plugins managed by [tpm](https://github.com/tmux-plugins/tpm). After editing `.tmux.conf`, run `tmux source ~/.tmux.conf` or press `prefix + r`, then `prefix + I` to install new plugins.

Zsh auto-attaches to (or creates) a session named `main` on every new terminal.

## Shell (.zshrc)

- Oh My Zsh with powerlevel10k theme
- Plugins: git, sudo, ssh-agent, docker, fzf, zoxide, pyenv
- Key aliases: `lg` → lazygit, `ld` → lazydocker, `j` → zoxide jump, `l`/`ls`/`ll`/`lt` → eza variants, `mux <navn>` → `tmuxp load <navn>`
- pyenv and nvm are initialized lazily if present

## Kitty (native)

`kitty/kitty.conf` — uses JetBrainsMono Nerd Font, cursor trail animation, and `include current-theme.conf` for theming.

**First-time theme setup:** run `kitty +kitten themes`, search for "Gruvbox Dark", and confirm — this writes `~/.config/kitty/current-theme.conf` and adds the include to `kitty.conf`.

SSH kitten is aliased automatically in `.zshrc` when `$TERM == xterm-kitty`, so plain `ssh` forwards kitty's terminfo and shell integration to the remote host.

## WezTerm (WSL only)

`wezterm/wezterm.lua` — used on Windows with WSL. Maximizes on startup, JetBrainsMono Nerd Font, Gruvbox Dark. The install script copies it to `/mnt/c/Users/sondr/.config/wezterm` on WSL; it is not installed or symlinked on native Arch.
