-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

-- OpenTofu uses .tofu alongside .tf; Neovim has no built-in detection for it.
vim.filetype.add({
  extension = {
    tofu = "terraform",
  },
})
