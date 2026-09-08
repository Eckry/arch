local servers = {
  "lua_ls",
  "pyright",
  "jsonls",
  "clangd",
  "ts_ls",
  "cssls",
  "vtsls",
  "html",
}

local settings = {
  ui = {
    border = "none",
    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    },
  },
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
}

require("mason").setup(settings)

require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_enable = false,
})

local handlers = require("plugins.lsp.handlers")

for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
  })

  vim.lsp.enable(server)
end
