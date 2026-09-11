-- Guardia para archivos grandes.
-- Neovim solo es lento en archivos grandes por lo que le colgamos encima
-- (treesitter, LSP, ibl, gitsigns). Aqui lo apagamos antes de que se cargue.
--
-- VSCode hace exactamente esto por defecto (editor.largeFileOptimizations);
-- nvim no trae nada asi de fabrica.

local M = {}

-- Umbrales altos a proposito: treesitter y el LSP NO eran el cuello de botella.
-- Medido: parse completo de un json de 500k lineas = 363 ms, redraw = 0.36 ms.
-- Lo que mataba la sesion era el undo persistente (ver lua/user/undo.lua), que
-- se limita aparte y con umbrales mucho mas bajos. Aqui solo protegemos contra
-- lo verdaderamente patologico, para no perder colores en un json de 30k lineas.
M.max_bytes = 5 * 1024 * 1024 -- 5 MB
M.max_lines = 100000
M.max_line_length = 2000 -- una sola linea kilometrica (json minificado)

--- @return boolean
function M.is_big(bufnr)
  if vim.b[bufnr].bigfile ~= nil then
    return vim.b[bufnr].bigfile
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  local ok, stats = pcall(vim.uv.fs_stat, name)
  local big = false
  if ok and stats and stats.size > M.max_bytes then
    big = true
  elseif vim.api.nvim_buf_line_count(bufnr) > M.max_lines then
    big = true
  else
    -- una linea muy larga cuesta mas que muchas cortas
    local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
    if first and #first > M.max_line_length then
      big = true
    end
  end
  vim.b[bufnr].bigfile = big
  return big
end

local function disable(bufnr)
  vim.b[bufnr].bigfile = true

  -- treesitter: el parse completo de 500k lineas cuesta ~360 ms y se repite
  pcall(vim.treesitter.stop, bufnr)
  vim.bo[bufnr].syntax = "" -- tampoco el regex highlighter

  -- indent-blankline recalcula el scope con treesitter en cada movimiento
  pcall(function()
    require("ibl").setup_buffer(bufnr, { enabled = false })
  end)

  -- opciones de buffer/ventana caras
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undofile = false -- el undo de un formateo masivo es enorme
  vim.bo[bufnr].undolevels = -1
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.spell = false
  vim.opt_local.list = false
  vim.opt_local.cursorline = false
  vim.opt_local.relativenumber = false -- fuerza redibujar la columna al moverse
  vim.opt_local.colorcolumn = ""
  vim.opt_local.signcolumn = "no"
  vim.opt_local.synmaxcol = 200

  -- LSP: el servidor no aporta nada util en un dump de datos y si te
  -- cuesta CPU (validacion, symbols, semantic tokens, didChange completo)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
    pcall(vim.diagnostic.enable, false, { bufnr = bufnr })
    -- gitsigns: recalcular el diff de un archivo enorme en cada cambio
    pcall(function()
      require("gitsigns").detach(bufnr)
    end)
  end)

  vim.notify(
    "Archivo grande: treesitter, LSP, ibl y gitsigns desactivados en este buffer",
    vim.log.levels.WARN
  )
end

function M.setup()
  local group = vim.api.nvim_create_augroup("BigFileGuard", { clear = true })

  -- BufReadPre: antes de que arranquen los plugins de este buffer
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = group,
    callback = function(args)
      local ok, stats = pcall(vim.uv.fs_stat, args.match)
      if ok and stats and stats.size > M.max_bytes then
        vim.b[args.buf].bigfile = true
        vim.bo[args.buf].undofile = false
        vim.bo[args.buf].swapfile = false
        -- evita que el detector de filetype dispare LSP y treesitter
        vim.b[args.buf].bigfile_pending = true
      end
    end,
  })

  -- BufReadPost: ya tenemos las lineas, aplicamos el resto
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
      if vim.b[args.buf].bigfile_pending or M.is_big(args.buf) then
        disable(args.buf)
      end
    end,
  })
end

return M
