return {
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      -- keybindings live in lua/config/keymaps.lua
      require("nvim-tmux-navigation").setup({
        disable_when_zoomed = true, -- defaults to false
      })
    end,
  },
}
