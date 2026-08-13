return {
  {
    "mistricky/codesnap.nvim", -- v2: precompiled generator, no build step
    keys = {
      { "<leader>cs", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save code snapshot to clipboard" },
      {
        "<leader>cS",
        function()
          local path = vim.fn.expand("~/Pictures/codesnap-" .. os.date("%Y%m%d_%H%M%S") .. ".png")
          vim.cmd("CodeSnapSave " .. path)
        end,
        mode = "x",
        desc = "Save code snapshot to disk",
      },
    },
    opts = {
      show_line_number = true,
      snapshot_config = {
        watermark = { content = "" },
        background = "#00000000",
        window = {
          mac_window_bar = false,
          shadow = { radius = 0, color = "#00000000" },
          border = { width = 0, color = "#00000000" },
          margin = { x = 0, y = 0 },
          radius = 0,
        },
      },
    },
  },
}
