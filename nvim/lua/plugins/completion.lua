-- Jump past an auto-closed pair instead of inserting a tab.
-- Tab/CR are `expr` mappings in blink.cmp, so the returned string is fed back
-- to Neovim; moving the cursor directly (e.g. nvim_win_set_cursor) inside the
-- handler gets silently reverted once the expr evaluation finishes.
local function skip_closer()
  local closers = { [")"] = true, ["]"] = true, ["}"] = true, ['"'] = true, ["'"] = true, ["`"] = true }
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
  if closers[char] then
    return vim.api.nvim_replace_termcodes("<Right>", true, false, true)
  end
end

return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.completion.menu.auto_show = false

      opts.keymap = {
        preset = "super-tab",

        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "show_signature", "hide_signature", "fallback" },

        ["<CR>"] = { "accept", "fallback" },

        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          skip_closer,
          "fallback",
        },
      }
    end,
  },

  {
    "nvim-mini/mini.snippets",
    opts = {
      -- Restore stop-on-<esc> (LazyVim disables it by default) so an
      -- abandoned snippet session doesn't leave tabstops dangling.
      mappings = { stop = "<esc>" },
    },
  },
}
