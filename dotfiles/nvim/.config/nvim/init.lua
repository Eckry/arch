require("user.options")
require("user.undo").setup()      -- limita el undo persistente (ver lua/user/undo.lua)
require("user.bigfile").setup()   -- antes de lazy: registra BufReadPre primero
require("config.lazy")
require("user.keymaps")
require("user.cp").setup()        -- competitive programming: <leader>rr / <F5>
