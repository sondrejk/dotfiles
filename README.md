## Useful commands


### Installing programs
## Must haves
```bash
sudo pacman -S neovim obsidian bitwarden zoxide bat fzf ripgrep docker docker-compose zsh tmux fd poetry npm yarn pyenv lazygit lazydocker steam uv ark btop dolphin jq fastfetch eza firefox git zed wezterm wget curl gvim github-cli pass pass-otp pnpm tldr unzip xclip
```
## Nice to have
```bash
sudo pacman -S discord godot prismlauncher qemu-full tailscale gdb valgrind
```

## From AUR
```bash
yay -S gowall visual-studio-code-bin vim-gruvbox-git spotify tmuxinator
```

## For xbox one controller
```bash
yay -S xone-dkms
```


### oh-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Jetbrains mono font
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
```

### Creating wallpapers\
https://github.com/Achno/gowall

### For Spotify local playback
```bash
sudo pacman -S ffmpeg4.4 zenity
```

### How to hide systemd boot menu on startup.
```bash
su root
vim /etc/loader/loader.conf
```
Change `timeout` to `menu-hidden`

### How to fix minecraft crashing from openal
in ~/.alsoftrc
```bash
[general]
drivers=pulse
hrtf=true
```
