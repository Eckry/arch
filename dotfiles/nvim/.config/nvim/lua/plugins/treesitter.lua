local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require "nvim-treesitter.configs".setup {
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "cpp", "javascript", "typescript", "css", "html" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    config = function()
      require("nvim-treesitter.configs").setup {
        refactor = {
          highlight_definitions = { enable = true },
          highlight_current_scope = { enable = true }, -- set true if you’d like
        },
        smart_rename = {
          enable = true,
          -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
          keymaps = {
            smart_rename = "grr",
          },
          navigation = {
            enable = true,
            -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
            keymaps = {
              goto_definition = "gnd",
              list_definitions = "gnD",
              list_definitions_toc = "gO",
              goto_next_usage = "<a-*>",
              goto_previous_usage = "<a-#>",
            },
          },
        },
      }
    end
  },
  {
    "HiPhish/rainbow-delimiters.nvim"
  }
}

return M
