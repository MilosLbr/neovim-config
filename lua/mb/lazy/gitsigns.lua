-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
-- Adds git related signs to the gutter, as well as utilities for managing changes

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          gitsigns.nav_hunk 'next'
        end, { desc = 'Go to next git [C]hange' })
        map('n', '[c', function()
          gitsigns.nav_hunk 'prev'
        end, { desc = 'Go to previous git [C]hange' })

        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git [H]unk [R]eset', silent = true })
      end,
    },
  },
}
