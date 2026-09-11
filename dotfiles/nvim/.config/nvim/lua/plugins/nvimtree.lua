return {
  "nvim-tree/nvim-tree.lua",
  -- Sin `keys`: el keymap real (<leader>e) vive en lua/user/keymaps.lua y llama
  -- a :NvimTreeToggle, que ya dispara la carga por `cmd`. Un stub de lazy aqui
  -- solo compite con ese keymap.
  cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeRefresh", "NvimTreeFocus", "NvimTreeOpen" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  -- `nvim .` (o `nvim <directorio>`) tiene que abrir el arbol, como antes.
  -- nvim-tree lo hace con hijack_directories, pero eso exige que el plugin este
  -- cargado al arrancar. Lo cargamos SOLO en ese caso: abrir `nvim archivo.ts`
  -- sigue sin tocar nvim-tree.
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("NvimTreeOpenDir", { clear = true }),
      callback = function()
        local arg = vim.fn.argv(0)
        if type(arg) ~= "string" or arg == "" then
          return
        end
        if vim.fn.isdirectory(arg) ~= 1 then
          return
        end
        require("nvim-tree.api").tree.open({ path = arg })
      end,
    })
  end,
  config = function()

    require("nvim-tree").setup {
      sort = { sorter = "case_sensitive" },
      view = {
        width = 35,
        side = "left",
        relativenumber = true,
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        indent_markers = { enable = true },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "",
              arrow_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      filters = {
        dotfiles = false,
        custom = { "^.git$", "node_modules", ".cache" },
      },
      git = { enable = true, ignore = false },
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = { enable = true },
        },
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      diagnostics = {
        enable = false,
        -- show_on_dirs = true,
        -- icons = { hint = "", info = "", warning = "", error = "" },
      },
    }

  end,
}
