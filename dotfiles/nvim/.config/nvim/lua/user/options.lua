vim.opt.clipboard = "unnamedplus"   -- use system clipboard
vim.opt.mouse = "a"                 -- enable mouse in all modes
vim.opt.undofile = true             -- persistent undo across sessions
vim.opt.swapfile = false            -- disable swap files
vim.opt.backup = false              -- disable backups
vim.opt.updatetime = 350            -- faster CursorHold, diagnostics
vim.opt.timeoutlen = 300            -- mapped sequence wait timeim.opt.clipboard = "unnamedplus"
vim.opt.number = true               -- absolute line numbers
vim.opt.relativenumber = true       -- relative numbers (great for motions)
vim.opt.cursorline = true           -- highlight current line
vim.opt.scrolloff = 8               -- keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8           -- horizontal equivalent
vim.opt.tabstop = 2                 -- visual width of a tab
vim.opt.shiftwidth = 2              -- indent width for >> and 
vim.opt.softtabstop = 2
vim.opt.expandtab = true            -- tabs -> spaces
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true          -- wrapped lines keep indent
vim.opt.ignorecase = true           -- case-insensitive search...
vim.opt.smartcase = true            -- ...unless capital letters used
vim.opt.hlsearch = true             -- highlight matches
vim.opt.incsearch = true            -- show matches while typing
vim.opt.splitright = true           -- vertical splits open right
vim.opt.splitbelow = true           -- horizontal splits open below
vim.opt.signcolumn = "yes"          -- always show sign column (no jitter)
vim.opt.termguicolors = true        -- 24-bit colors
vim.opt.wrap = false                -- don't wrap long lines
vim.opt.showmode = false            -- hide -- INSERT -- (statusline shows it)
vim.opt.cmdheight = 1
vim.opt.pumheight = 10              -- max popup menu items
vim.opt.completeopt = "menuone,noselect"  -- better completion UX
vim.opt.inccommand = "nosplit"      -- live preview of :substitute ("split" abre
                                    -- una ventana con TODAS las coincidencias y
                                    -- la recalcula en cada tecla: ~100 ms/tecla
                                    -- en un archivo de 500k lineas)
vim.opt.virtualedit = "block"       -- cursor past EOL in visual block
vim.opt.confirm = true              -- prompt instead of failing on :q
vim.opt.fileencoding = "utf-8"
vim.opt.list = true                 -- show whitespace chars
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:block"

vim.opt.iskeyword:append("-")     -- treat dash-separated words as one word
vim.opt.whichwrap:append("<,>,[,],h,l") -- arrows/h/l wrap to prev/next line
vim.cmd([[set formatoptions-=cro]]) -- don't auto-continue comments on o/O/Enter

-- ── rendimiento en archivos grandes ──────────────────────────────────────────
vim.opt.synmaxcol = 300             -- no colorear mas alla de la columna 300
                                    -- (json minificado = una linea de 300 KB)
vim.opt.redrawtime = 1500           -- si el highlight tarda mas, se rinde en vez
                                    -- de congelar la interfaz
vim.opt.maxmempattern = 20000       -- mas memoria para regex antes de fallar
vim.opt.ttimeoutlen = 10            -- no esperes por secuencias de escape

-- el log del LSP estaba en 11 MB: se escribe en disco de forma sincrona
vim.lsp.set_log_level("off")

