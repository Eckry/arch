return {
  {
  "nvim-tree/nvim-tree.lua",
  dependencies = {"nvim-tree/nvim-web-devicons"},
  config = function ()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true
    require("nvim-tree").setup {
        filters = {
          enable = true,
          git_ignored = false,
          dotfiles = false,
          git_clean = false,
          no_buffer = false,
          no_bookmark = false,
          custom = {},
          exclude = {},
      },
    }
  end
  }
}
