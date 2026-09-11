return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  ---@module "ibl"
  ---@type ibl.config
  config = function()
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }

    -- define the rainbow colors used for indent levels
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed",    { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowBlue",   { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen",  { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan",   { fg = "#56B6C2" })
    end)

    require("ibl").setup({
      indent = {
        char = "│",          -- thin vertical line; try "▏" for thinner
        highlight = highlight,
      },
      scope = {
        enabled = true,
        show_start = true,    -- underline the line that opens the scope
        show_end = false,
        highlight = highlight,
      },
      -- el scope se calcula con treesitter en cada movimiento del cursor;
      -- en json muy anidado y grande eso se siente
      exclude = {
        buftypes = { "terminal", "nofile", "quickfix", "prompt" },
        filetypes = {
          "help",
          "dashboard",
          "NvimTree",
          "lazy",
          "mason",
          "toggleterm",
          "trouble",
        },
      },
    })
  end,
}
