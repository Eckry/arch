-- Highlight con la API nativa de nvim 0.11 (vim.treesitter.start).
-- nvim-treesitter queda SOLO como instalador de parsers (:TSUpdate/:TSInstall)
-- y como proveedor de textobjects, ambos perezosos.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSInstall", "TSInstallSync", "TSUpdateSync", "TSModuleInfo", "TSBufToggle" },
    init = function()
      local bigfile = require("user.bigfile")
      -- los parsers (.so) y las queries viven DENTRO del directorio del plugin.
      -- Sin esto en el rtp, vim.treesitter no encuentra nada y el highlight
      -- se apaga en silencio. Anadir la ruta NO carga el modulo lua.
      vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter")

      -- filetype -> nombre del parser, cuando no coinciden. Este mapeo lo hacia
      -- nvim-treesitter al cargarse; sin el, tsx se queda sin colores.
      for ft, lang in pairs({
        typescriptreact = "tsx",
        javascriptreact = "javascript",
        ["javascript.jsx"] = "javascript",
        ["typescript.tsx"] = "tsx",
      }) do
        vim.treesitter.language.register(lang, ft)
      end
      -- parsers que ya tienes instalados; encender el highlight nativo por filetype
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TSNativeHighlight", { clear = true }),
        callback = function(args)
          if bigfile.is_big(args.buf) then return end
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then return end
          -- no bloquea si el parser no esta instalado
          local ok = pcall(vim.treesitter.start, args.buf, lang)
          if ok then
            -- folding y indent siguen siendo de vim (mas rapidos)
            vim.bo[args.buf].syntax = ""
          end
        end,
      })
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "cpp", "c", "json", "python", "markdown", "xml", "markdown_inline", "typescript", "tsx", "javascript" },
        highlight = { enable = false }, -- lo hace vim.treesitter.start
        indent = { enable = false },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "af", mode = { "x", "o" } }, { "if", mode = { "x", "o" } },
      { "ac", mode = { "x", "o" } }, { "ic", mode = { "x", "o" } },
      { "aa", mode = { "x", "o" } }, { "ia", mode = { "x", "o" } },
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true, lookahead = true,
            keymaps = {
              ["af"] = "@function.outer", ["if"] = "@function.inner",
              ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",["ia"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = { "grr", "gnd", "gnD", "gO", "<a-*>", "<a-#>" },
    config = function()
      require("nvim-treesitter.configs").setup({
        refactor = {
          highlight_definitions = { enable = true },
          highlight_current_scope = { enable = false },
          smart_rename = {
            enable = true,
            keymaps = { smart_rename = "grr" },
          },
          navigation = {
            enable = true,
            keymaps = {
              goto_definition = "gnd",
              list_definitions = "gnD",
              list_definitions_toc = "gO",
              goto_next_usage = "<a-*>",
              goto_previous_usage = "<a-#>",
            },
          },
        },
      })
    end,
  },
}
