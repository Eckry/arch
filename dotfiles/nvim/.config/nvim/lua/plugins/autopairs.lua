return {
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        fast_wrap = { map = '<C-s>' }
      })
    end
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  }
}
