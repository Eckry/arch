local M = {}

M.setup = function()
  local config = {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '',
        [vim.diagnostic.severity.WARN]  = '',
        [vim.diagnostic.severity.INFO]  = '',
        [vim.diagnostic.severity.HINT]  = '󰌵',
      },
    },
    virtual_text = true,
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }
  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client, bufnr)
  if client.server_capabilities and client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      buffer = bufnr,
      callback = function() vim.lsp.buf.document_highlight() end,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = bufnr,
      callback = function() vim.lsp.buf.clear_references() end,
    })
  end
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local function bufmap(mode, lhs, rhs)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  end

  bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
  bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
  bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
  bufmap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
  bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
  bufmap("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>')
  bufmap("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>')
  bufmap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")
end

M.on_attach = function(client, bufnr)
  -- apply keymaps and document highlight
  lsp_keymaps(bufnr)
  lsp_highlight_document(client, bufnr)

  -- helper to check formatting capability
  local function client_supports_format(c)
    if not c then return false end
    if c.supports_method then
      return c.supports_method("textDocument/formatting") or c.supports_method("textDocument/rangeFormatting")
    end
    local caps = c.server_capabilities or c.resolved_capabilities
    return caps and (caps.documentFormattingProvider or caps.documentRangeFormattingProvider)
  end

  -- If this client can't format, don't create format autocommands/commands for it
  if not client_supports_format(client) then
    return
  end

  -- create a buffer-local Format command that uses *this* client only
  if vim.api.nvim_buf_create_user_command then
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
      vim.lsp.buf.format({
        bufnr = bufnr,
        async = true,
        filter = function(c) return c.id == client.id end,
      })
    end, { desc = "Format current buffer with attached LSP client" })
  else
    -- fallback for older nvim (global command)
    vim.api.nvim_create_user_command("Format", function()
      vim.lsp.buf.format({
        bufnr = bufnr,
        async = true,
        filter = function(c) return c.id == client.id end,
      })
    end, {})
  end

  -- create a unique augroup for this buffer so autocmds don't conflict
  local augroup = vim.api.nvim_create_augroup("LspFormatting_" .. bufnr, { clear = true })

  -- Format on save using *this* client only
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
      vim.lsp.buf.format({
        async = false,
      })
    end,
  })
end

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_ok then
  M.capabilities = cmp_nvim_lsp.default_capabilities()
end

return M
