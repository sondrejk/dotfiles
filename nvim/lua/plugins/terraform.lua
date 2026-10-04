-- Only `tofu` (OpenTofu) is installed, not `terraform`, so redirect the
-- lang.terraform extra's tooling at it instead of its terraform-cli defaults.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {
          init_options = {
            terraformExecPath = "tofu",
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        terraform = { "tofu" },
        tf = { "tofu" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        hcl = { "tofu_fmt" },
        terraform = { "tofu_fmt" },
        tf = { "tofu_fmt" },
        ["terraform-vars"] = { "tofu_fmt" },
      },
    },
  },
  {
    -- Drop the extra's null-ls sources: they shell out to `terraform`/`packer`,
    -- neither of which is installed, and conform+nvim-lint above already cover
    -- formatting and validation via `tofu`.
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local dropped = { terraform_fmt = true, terraform_validate = true, packer = true }
      opts.sources = vim.tbl_filter(function(source)
        return not dropped[source.name]
      end, opts.sources or {})
    end,
  },
}
