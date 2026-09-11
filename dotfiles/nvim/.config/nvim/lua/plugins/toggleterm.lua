return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = { [[<c-\>]] },
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\>]],   -- Ctrl-\ to toggle
      direction = "float",
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,     -- open_mapping works in insert mode too
      terminal_mappings = true,   -- and inside the terminal
      persist_size = true,
      persist_mode = true,
      close_on_exit = true,
      float_opts = {
        border = "curved",        -- nice rounded border
        width = function() return math.floor(vim.o.columns * 0.85) end,
        height = function() return math.floor(vim.o.lines * 0.85) end,
        winblend = 3,             -- slight transparency
        title_pos = "center",
      },
    })

    -- Easier escape out of terminal insert mode + window navigation
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-q>", [[<Cmd>ToggleTerm<CR>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end
    vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")
  end,
}
