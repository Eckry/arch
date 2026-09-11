return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lemminx", "sqls", "vtsls", "eslint", "cssls", "html", "lua_ls" },
        automatic_enable = false, -- lsp.lua ya hace vim.lsp.enable()
      })
    end,
  },
}
