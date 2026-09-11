return {
    'MeanderingProgrammer/render-markdown.nvim',
    -- 'nvim-mini/mini.nvim' carga la suite COMPLETA de mini solo para los iconos.
    -- mini.icons es el unico modulo que hace falta.
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
    ft = { 'markdown', 'md', 'rmd', 'Avante', 'codecompanion' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        -- render-markdown recalcula el render del buffer visible en cada cambio
        max_file_size = 2.0, -- MB
    },
}
