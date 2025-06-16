## Useful commands

### yay settings
```bash
yay --save --answerdiff None --answerclean None --removemake
```
This creates a file in `~/.config/yay/config.json` to save the preference

### Installing programs
```bash
sudo pacman -S ghostty neovim obsidian bitwarden zoxide bat fzf ripgrep docker docker-compose discord zsh tmux fd poetry npm yarn pyenv lazygit steam jdk-openjdk
```

### yay installations
```bash
yay -S spotify gowall visual-studio-code-bin java-openjfx
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
```bash
[general]
drivers=pulse
hrtf=true
```
in ~/.alsoftrc
