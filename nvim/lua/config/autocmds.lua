-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Typst: <leader>cp compiles once, runs `typst watch` fully in the background
-- (no visible pane), launches zathura (which auto-reloads on file change),
-- and tiles the terminal + zathura side by side via KWin scripting (see
-- kwin/*.js; a no-op if gdbus/KWin scripting isn't available).
-- tdf (a TUI pdf viewer via the kitty graphics protocol) was tried instead of
-- zathura so the preview could live in a tmux split, but its kitty-graphics
-- support is broken under tmux: https://github.com/itsjunetime/tdf/issues/57
-- Start-only, not a toggle: close the process/window by hand when done.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(event)
    vim.keymap.set("n", "<leader>cp", function()
      local kwin_dir = vim.fn.stdpath("config") .. "/kwin"
      local run_kwin = kwin_dir .. "/run-script.sh"

      -- Tile now, while the terminal still has focus (before zathura steals it).
      vim.fn.system({ run_kwin, kwin_dir .. "/tile-left.js" })

      local file = vim.api.nvim_buf_get_name(event.buf)
      local pdf = vim.fn.fnamemodify(file, ":r") .. ".pdf"
      vim.fn.system({ "typst", "compile", file })
      vim.fn.system("setsid -f typst watch " .. vim.fn.shellescape(file) .. " >/dev/null 2>&1 &")
      vim.fn.system("setsid -f zathura " .. vim.fn.shellescape(pdf) .. " >/dev/null 2>&1 &")

      -- Give zathura's window time to map before tiling/refocusing.
      vim.defer_fn(function()
        vim.fn.system({ run_kwin, kwin_dir .. "/tile-right-refocus.js" })
      end, 900)
    end, { buffer = event.buf, desc = "Typst: watch + zathura preview (tiled)" })
  end,
})
