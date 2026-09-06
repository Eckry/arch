require("user.lazy")
require("user.options")
require("user.keymaps")
local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end
require("plugins.lsp.handlers").setup()
require("plugins.lsp.mason")
require("user.snippets")
