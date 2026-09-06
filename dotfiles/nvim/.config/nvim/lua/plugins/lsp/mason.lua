local servers = {
  "lua_ls",
  "pyright",
  "jsonls",
  "clangd",
  "ts_ls",
  "cssls",
  "vtsls",
  "html"
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
  automatic_installation = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

for _, server in pairs(servers) do
  local opts = {
    on_attach = require("plugins.lsp.handlers").on_attach,
    capabilities = require("plugins.lsp.handlers").capabilities,
  }
  server = vim.split(server, "@")[1]
  lspconfig[server].setup(opts) -- THIS is what actually registers your on_attach
end
