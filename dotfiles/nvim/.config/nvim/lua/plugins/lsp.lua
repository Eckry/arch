return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- diagnostics display (unchanged)
    vim.diagnostic.config({
      virtual_text = { prefix = "●", spacing = 2 },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = true },
    })

    local caps = require("cmp_nvim_lsp").default_capabilities()

    -- set capabilities for ALL servers at once
    vim.lsp.config("*", {
      capabilities = caps,
    })

    -- per-server config (only when you need to override something)
    vim.lsp.config("clangd", {
      cmd = { "clangd" },
    })

    vim.lsp.config("pyright", {})

    vim.lsp.config("jsonls", {
      settings = {
        json = {
          -- topes de jsonls: sin esto calcula symbols/folding/colores para
          -- TODO el documento en cada cambio
          maxItemsComputed = 5000,
          format = { enable = false }, -- formateamos con jq, es 50x mas rapido
        },
      },
    })
    vim.lsp.config("lemminx", {})
    vim.lsp.config("sqls", {})
    vim.lsp.config("vtsls", {})
    vim.lsp.config("cssls", {})
    vim.lsp.config("html", {})

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    local eslint_base_on_attach = vim.lsp.config.eslint.on_attach
    vim.lsp.config("eslint", {
      on_attach = function(client, bufnr)
        if eslint_base_on_attach then
          eslint_base_on_attach(client, bufnr)
        end
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            -- eslint --fix bloquea el guardado; no lo corras en archivos grandes
            if not require("user.bigfile").is_big(bufnr) then
              vim.cmd("LspEslintFixAll")
            end
          end,
        })
      end,
    })

    -- no arranques servidores en archivos grandes: el didChange, la validacion
    -- y los semantic tokens de un documento de varios MB cuestan mucha CPU
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        if require("user.bigfile").is_big(args.buf) then
          vim.schedule(function()
            vim.lsp.buf_detach_client(args.buf, args.data.client_id)
          end)
          return
        end
        -- los semantic tokens son el mensaje mas grande que manda un servidor;
        -- treesitter ya colorea, asi que en archivos medianos no los necesitas
        if vim.api.nvim_buf_line_count(args.buf) > 5000 then
          client.server_capabilities.semanticTokensProvider = nil
        end
      end,
    })

    -- enable them
    vim.lsp.enable({
      "clangd", "pyright", "jsonls", "lemminx", "sqls", "vtsls", "eslint",
      "cssls", "html", "lua_ls",
    })
  end,
}
