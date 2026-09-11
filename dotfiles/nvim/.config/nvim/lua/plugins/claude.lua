return {
  "greggh/claude-code.nvim",
  cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume" },
  keys = { "<leader>c", "<leader>cc", "<C-,>" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("claude-code").setup({
      -- Terminal window settings
      window = {
        split_ratio = 0.4,        -- 40% of the screen for the Claude window
        position = "horizontal",    -- "vertical", "horizontal", "float", "botright", etc.
        enter_insert = true,      -- jump straight into insert mode when opening
        hide_numbers = true,
        hide_signcolumn = true,

        -- floating window options (used when position = "float")
        float = {
          width = "80%",
          height = "80%",
          row = "center",
          col = "center",
          border = "rounded",
        },
      },

      -- Auto-reload files Claude edits, so your buffers stay in sync
      refresh = {
        enable = true,
        updatetime = 100,          -- ms; lowered while Claude Code is open
        timer_interval = 1000,     -- check for external changes every 1s
        show_notifications = true,
      },

      git = {
        use_git_root = true,       -- run Claude from the git repo root
      },

      -- Use the `claude` CLI on your PATH
      command = "claude",

      -- Keymaps
      keymaps = {
        toggle = {
          normal = "<C-,>",        -- toggle Claude window in normal mode
          terminal = "<C-,>",      -- and from inside the terminal
        },
        window_navigation = true,  -- <C-h/j/k/l> to move between windows
        scrolling = true,          -- <C-f>/<C-b> to scroll the Claude output
      },
    })
  end,
}
