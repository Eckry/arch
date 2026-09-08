local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
          "cpp",
          "javascript",
          "typescript",
          "css",
          "html",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-refactor",
    config = function()
      require("nvim-treesitter.configs").setup({
        refactor = {
          highlight_definitions = {
            enable = false,
          },
          highlight_current_scope = {
            enable = true,
          },
        },
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = "grr",
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

  {
    "HiPhish/rainbow-delimiters.nvim",
  },
}

return M
