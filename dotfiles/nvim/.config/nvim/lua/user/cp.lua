-- Competitive programming runner.
-- Compiles the current C++ buffer, feeds it input.txt, writes stdout to
-- output.txt. Opens no windows: the result is a one-line message in the
-- cmdline, and output.txt reloads in place if you keep it open in a split.
-- Compile errors are the one exception -- they open quickfix, so <CR> jumps
-- straight to the offending line.

local M = {}

M.opts = {
  input = "input.txt",
  output = "output.txt",
  timeout = 10000, -- ms; kills runaway loops instead of freezing nvim
  flags = {
    "-std=c++20", "-O2", "-Wall", "-Wextra", "-Wshadow",
    "-fsanitize=address,undefined", "-fno-sanitize-recover=all",
    "-D_GLIBCXX_ASSERTIONS", "-DLOCAL",
  },
}

M.last_stderr = {}

-- Split a captured stream into lines, dropping the trailing newline.
local function to_lines(s)
  if not s or s == "" then return {} end
  return vim.split((s:gsub("\r\n", "\n"):gsub("\n$", "")), "\n", { plain = true })
end

-- One-line status in the cmdline. Never triggers a "Press ENTER" prompt.
local function say(msg, hl)
  vim.api.nvim_echo({ { "cp: " .. msg, hl } }, false, {})
end

local function execute(bin, dir, infile, outfile)
  local stdin = ""
  local f = io.open(infile, "r")
  if f then
    stdin = f:read("*a")
    f:close()
  end

  local t0 = vim.uv.hrtime()

  vim.system({ bin }, { cwd = dir, text = true, stdin = stdin, timeout = M.opts.timeout },
    function(r)
      local ms = (vim.uv.hrtime() - t0) / 1e6
      vim.schedule(function()
        local wf = io.open(outfile, "w")
        if wf then
          wf:write(r.stdout or "")
          wf:close()
        end
        vim.cmd("silent! checktime") -- reload output.txt if it is open somewhere

        M.last_stderr = to_lines(r.stderr)

        if ms >= M.opts.timeout - 50 then
          say(string.format("TIMEOUT after %d ms", M.opts.timeout), "ErrorMsg")
          return
        end

        local msg = string.format("exit %d · %.0f ms", r.code, ms)
        if #M.last_stderr > 0 then
          msg = msg .. string.format(" · %d stderr line(s), :CpErr", #M.last_stderr)
        end
        say(msg, r.code == 0 and "MoreMsg" or "ErrorMsg")
      end)
    end)
end

function M.run()
  local src = vim.api.nvim_buf_get_name(0)
  if not (src:match("%.cpp$") or src:match("%.cc$") or src:match("%.cxx$")) then
    say("current buffer is not a C++ source file", "WarningMsg")
    return
  end
  vim.cmd("silent! write")

  local dir = vim.fs.dirname(src)
  local bin = (src:gsub("%.%w+$", "")) .. ".exe"
  local infile = dir .. "/" .. M.opts.input
  local outfile = dir .. "/" .. M.opts.output

  say("compiling...", "MoreMsg")

  local cmd = { "g++" }
  vim.list_extend(cmd, M.opts.flags)
  vim.list_extend(cmd, { "-o", bin, src })

  vim.system(cmd, { cwd = dir, text = true }, function(cc)
    vim.schedule(function()
      local diags = to_lines(cc.stderr)
      vim.fn.setqflist({}, " ", { title = "g++", lines = diags, efm = vim.o.errorformat })

      if cc.code ~= 0 then
        say("compilation failed", "ErrorMsg")
        vim.cmd("copen")
        return
      end

      vim.cmd("cclose") -- warnings stay in quickfix, but out of the way
      execute(bin, dir, infile, outfile)
    end)
  end)
end

-- Show the last run's stderr (sanitizer reports, cerr debugging) in quickfix.
function M.err()
  if #M.last_stderr == 0 then
    say("last run wrote nothing to stderr", "MoreMsg")
    return
  end
  vim.fn.setqflist({}, " ", { title = "stderr", lines = M.last_stderr, efm = vim.o.errorformat })
  vim.cmd("copen")
end

-- Open input.txt / output.txt next to the source file.
function M.edit(which)
  local src = vim.api.nvim_buf_get_name(0)
  local dir = src ~= "" and vim.fs.dirname(src) or vim.uv.cwd()
  vim.cmd("split " .. vim.fn.fnameescape(dir .. "/" .. M.opts[which]))
end

function M.setup()
  vim.api.nvim_create_user_command("CpRun", M.run, { desc = "Compile + run with input.txt" })
  vim.api.nvim_create_user_command("CpErr", M.err, { desc = "Last run's stderr in quickfix" })
  vim.api.nvim_create_user_command("CpInput", function() M.edit("input") end, { desc = "Edit input.txt" })
  vim.api.nvim_create_user_command("CpOutput", function() M.edit("output") end, { desc = "Open output.txt" })

  local map = vim.keymap.set
  map("n", "<leader>rr", M.run, { desc = "CP: compile + run" })
  map("n", "<F5>", M.run, { desc = "CP: compile + run" })
  map("i", "<F5>", "<Esc><cmd>CpRun<CR>", { desc = "CP: compile + run" })
  map("n", "<leader>ri", function() M.edit("input") end, { desc = "CP: edit input.txt" })
  map("n", "<leader>ro", function() M.edit("output") end, { desc = "CP: open output.txt" })
end

return M
