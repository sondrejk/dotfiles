# Extras

Commands and packages not handled by install-arch.sh.

## AUR packages

```bash
yay -S gowall visual-studio-code-bin vim-gruvbox-git spotify
```

## xv6 OS development

```bash
sudo pacman -S riscv64-gnu-binutils riscv64-elf-gcc qemu-system-misc
```

## Xbox One controller

```bash
yay -S xone-dkms
```

## Creating wallpapers

<https://github.com/Achno/gowall>

## Hide systemd boot menu on startup

```bash
su root
vim /etc/loader/loader.conf
```

Change `timeout` to `menu-hidden`.

## Fix Minecraft crashing from OpenAL

In `~/.alsoftrc`:

```ini
[general]
drivers=pulse
hrtf=true
```
