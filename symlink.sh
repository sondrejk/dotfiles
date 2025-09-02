rm ~/.tmux.conf
rm ~/.vimrc
rm ~/.zshrc
rm ~/.config/nvim
rm ~/.config/fastfetch
rm ~/.config/wezterm

ln -s "$(pwd)"/.tmux.conf ~/.tmux.conf
ln -s "$(pwd)"/.vimrc ~/.vimrc
ln -s "$(pwd)"/.zshrc ~/.zshrc
ln -s "$(pwd)"/nvim ~/.config/
ln -s "$(pwd)"/fastfetch ~/.config/
ln -s "$(pwd)"/wezterm ~/.config/
