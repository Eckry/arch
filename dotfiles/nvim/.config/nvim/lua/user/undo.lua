-- Control del undo persistente.
--
-- El problema que esto resuelve: `undofile = true` guarda el arbol de undo en
-- disco y ese archivo SOLO CRECE, nunca se limpia. Cada operacion que reemplaza
-- el buffer completo (ggVG"_dP, formatear 30k lineas, pegar un payload entero)
-- guarda un estado de undo con una copia integra del archivo. Con undolevels
-- en 1000, un json de 1.3 MB acaba produciendo un undofile de 12 GB.
--
-- Y al abrir el archivo, nvim lee ese undofile completo A MEMORIA: 11 GB de RSS,
-- swap, y el escritorio entero se congela.
--
-- Regla: el undo en la sesion siempre esta (undolevels), lo que se limita es la
-- PERSISTENCIA en disco, que en archivos de datos no vale lo que cuesta.

local M = {}

-- arriba de esto no se escribe undofile
M.max_persist_bytes = 512 * 1024 -- 512 KB
M.max_persist_lines = 10000

-- filetypes que son volcados de datos: el undo entre sesiones no sirve de nada
M.no_persist_ft = {
  json = true,
  jsonc = true,
  xml = true,
  csv = true,
  tsv = true,
  log = true,
  sql = true,
}

--- @return boolean, string|nil  razon
function M.should_persist(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if M.no_persist_ft[vim.bo[bufnr].filetype] then
    return false, "filetype " .. vim.bo[bufnr].filetype
  end

  if vim.api.nvim_buf_line_count(bufnr) > M.max_persist_lines then
    return false, vim.api.nvim_buf_line_count(bufnr) .. " lineas"
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" then
    local ok, stats = pcall(vim.uv.fs_stat, name)
    if ok and stats and stats.size > M.max_persist_bytes then
      return false, math.floor(stats.size / 1024) .. " KB"
    end
  end

  return true, nil
end

--- Borra los undofiles que pasen de `limit` bytes.
--- @param limit number|nil bytes (default 50 MB)
--- @param dry_run boolean|nil solo listar
function M.prune(limit, dry_run)
  limit = limit or 50 * 1024 * 1024
  local dir = vim.fn.stdpath("state") .. "/undo"
  local handle = vim.uv.fs_scandir(dir)
  if not handle then
    vim.notify("No existe " .. dir, vim.log.levels.WARN)
    return
  end

  local freed, count, lines = 0, 0, {}
  while true do
    local name, typ = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if typ == "file" then
      local path = dir .. "/" .. name
      local stats = vim.uv.fs_stat(path)
      if stats and stats.size > limit then
        freed = freed + stats.size
        count = count + 1
        table.insert(
          lines,
          string.format("  %8.1f MB  %s", stats.size / 1048576, (name:gsub("%%", "/")))
        )
        if not dry_run then
          vim.uv.fs_unlink(path)
        end
      end
    end
  end

  table.insert(
    lines,
    1,
    string.format(
      "%s %d undofiles, %.2f GB",
      dry_run and "[dry-run] se borrarian" or "Borrados",
      count,
      freed / 1073741824
    )
  )
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("UndoGuard", { clear = true })

  -- Decidir ANTES de escribir: si aqui dejamos undofile activo, nvim vuelca el
  -- arbol completo a disco justo despues de guardar.
  vim.api.nvim_create_autocmd({ "BufWritePre", "FileType" }, {
    group = group,
    callback = function(args)
      local persist, why = M.should_persist(args.buf)
      vim.bo[args.buf].undofile = persist
      if not persist then
        -- el undo en memoria sigue, pero acotado: 200 pasos de un archivo de
        -- 1 MB son 200 MB en el peor caso, no 12 GB
        vim.bo[args.buf].undolevels = 200
        vim.b[args.buf].undo_reason = why
      end
    end,
  })

  -- Aviso si al abrir un archivo ya existe un undofile monstruoso: sin esto
  -- nvim lo carga a memoria en silencio.
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = group,
    callback = function(args)
      local uf = vim.fn.undofile(args.match)
      local stats = uf ~= "" and vim.uv.fs_stat(uf) or nil
      if stats and stats.size > 100 * 1024 * 1024 then
        vim.bo[args.buf].undofile = false
        vim.opt_local.undoreload = 0 -- no recargues el arbol de undo
        vim.schedule(function()
          vim.notify(
            string.format(
              "undofile de %.1f GB ignorado (%s).\nCorre :UndoPrune para borrar los que sobran.",
              stats.size / 1073741824,
              vim.fn.fnamemodify(args.match, ":t")
            ),
            vim.log.levels.WARN
          )
        end)
      end
    end,
  })

  vim.api.nvim_create_user_command("UndoPrune", function(a)
    local mb = tonumber(a.args) or 50
    M.prune(mb * 1024 * 1024, a.bang)
  end, {
    nargs = "?",
    bang = true,
    desc = "Borra undofiles de mas de N MB (default 50). Con ! solo lista.",
  })

  vim.api.nvim_create_user_command("UndoInfo", function()
    local buf = vim.api.nvim_get_current_buf()
    local uf = vim.fn.undofile(vim.api.nvim_buf_get_name(buf))
    local stats = uf ~= "" and vim.uv.fs_stat(uf) or nil
    local persist, why = M.should_persist(buf)
    vim.notify(
      string.format(
        "undofile   : %s\nen disco   : %s\npersistir  : %s%s\nundolevels : %d",
        uf == "" and "(ninguno)" or uf,
        stats and string.format("%.1f MB", stats.size / 1048576) or "no existe",
        tostring(persist),
        why and ("  (" .. why .. ")") or "",
        vim.bo[buf].undolevels
      ),
      vim.log.levels.INFO
    )
  end, { desc = "Estado del undo de este buffer" })
end

return M
