return {
  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Mason
      {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
      },
      {
        "williamboman/mason-lspconfig.nvim",
      },
    },
    config = function()
      require("plugins.lsp") 
    end,
  },
}
