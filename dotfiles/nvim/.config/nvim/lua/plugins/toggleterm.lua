return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      local toggleterm = require("toggleterm")
      toggleterm.setup {
        direction = "float",
        float_opts = {
          border = 'curved',
          title_pos = 'center'
        },
      }
    end
  }
}
