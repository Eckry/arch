return {
  'nvim-telescope/telescope.nvim', version = '*',
  cmd = 'Telescope',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    { '<leader>f',  function() require('telescope.builtin').find_files() end, desc = 'Telescope find files' },
    { '<leader>fg', function() require('telescope.builtin').live_grep() end,  desc = 'Telescope live grep' },
    { '<leader>fb', function() require('telescope.builtin').buffers() end,    desc = 'Telescope buffers' },
    { '<leader>fh', function() require('telescope.builtin').help_tags() end,  desc = 'Telescope help tags' },
    { '<leader>fs', function() require('telescope.builtin').lsp_document_symbols() end, desc = 'Telescope document symbols' },
    { '<leader>fw', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, desc = 'Telescope workspace symbols' },
    { '<leader>fg', mode = 'v', function()
        vim.cmd('noautocmd normal! "vy')
        local text = vim.fn.getreg('v'):gsub('\n', ' ')
        require('telescope.builtin').live_grep({ default_text = text })
      end, desc = 'Telescope live grep selection' },
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    telescope.setup({
      defaults = {
        mappings = {
          i = { ["<C-j>"] = actions.move_selection_next, ["<C-k>"] = actions.move_selection_previous },
          n = { ["<C-j>"] = actions.move_selection_next, ["<C-k>"] = actions.move_selection_previous },
        },
      },
    })
    telescope.load_extension('fzf')
  end,
}
