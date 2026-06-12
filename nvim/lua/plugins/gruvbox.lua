return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optional: Configure palette or contrast
      -- vim.g.gruvbox_material_background = 'hard'

      -- Load the colorscheme
      vim.cmd([[colorscheme gruvbox-material]])
    end,
  },
}
