return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },   -- load right before a save
  cmd = { "ConformInfo" },
  config = function()
    local bigfile = require("user.bigfile")

    require("conform").setup({
      formatters_by_ft = {
        python   = { "ruff_format" },          -- fast; or { "isort", "black" }
        cpp      = { "clang_format" },
        c        = { "clang_format" },
        -- jq es C nativo: ~68 ms en 50k lineas.
        -- jsonls tarda 3.5 s en lo mismo porque devuelve un TextEdit por linea.
        json     = { "jq" },
        jsonc    = { "jq" },
        -- prettierd es un demonio: mantiene node caliente, igual que hace
        -- VSCode con su extension host. prettier normal paga ~300 ms de
        -- arranque de node en cada guardado.
        markdown = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        xml      = { "xmllint" },
        sql      = { "sql_formatter" },
      },

      -- nunca dejes que el LSP formatee json/xml: esos servidores devuelven
      -- miles de TextEdits individuales y aplicarlos es lo que congela nvim
      format_on_save = function(bufnr)
        if bigfile.is_big(bufnr) then
          return nil -- no formatear al guardar archivos enormes
        end
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        end
        local no_lsp_fallback = { json = true, jsonc = true, xml = true }
        return {
          timeout_ms = 5000,
          lsp_format = no_lsp_fallback[vim.bo[bufnr].filetype] and "never" or "fallback",
        }
      end,

      formatters = {
        jq = {
          prepend_args = { "--indent", "2" },
        },
        clang_format = {
          prepend_args = { "--style=file", "--fallback-style=LLVM" },
        },
        xmllint = {
          prepend_args = { "--format", "--encode", "utf-8" },
          env = { XMLLINT_INDENT = "  " },   -- 2 spaces, matches your config
        },
        sql_formatter = {
          prepend_args = { "--language", "tsql" },
        },
      },
    })

    -- manual format keymap
    vim.keymap.set({ "n", "v" }, "<leader>f", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local no_lsp_fallback = { json = true, jsonc = true, xml = true }
      require("conform").format({
        bufnr = bufnr,
        async = true,
        timeout_ms = 10000,
        lsp_format = no_lsp_fallback[vim.bo[bufnr].filetype] and "never" or "fallback",
      })
    end, { desc = "Format file or selection" })

    -- interruptor para apagar el formateo al guardar
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = "Disable format on save", bang = true })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "Re-enable format on save" })
  end,
}
