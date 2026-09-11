return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = { "<leader>a", "<leader>hd", "<C-e>", "<C-1>", "<C-2>", "<C-3>", "<C-4>", "<A-p>", "<A-n>" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
    vim.keymap.set("n", "<leader>hd", function() harpoon:list():remove() end, { desc = "Harpoon remove current file" })
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon quick menu" })

    vim.keymap.set("n", "<C-1>", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
    vim.keymap.set("n", "<C-2>", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
    vim.keymap.set("n", "<C-3>", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
    vim.keymap.set("n", "<C-4>", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

    vim.keymap.set("n", "<A-p>", function() harpoon:list():prev() end, { desc = "Harpoon prev file" })
    vim.keymap.set("n", "<A-n>", function() harpoon:list():next() end, { desc = "Harpoon next file" })
  end,
}
