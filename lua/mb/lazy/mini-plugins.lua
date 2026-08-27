-- Collection of various small independent plugins/modules
return {
  'echasnovski/mini.nvim',
  branch = 'main',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  config = function()
    local spec_treesitter = require('mini.ai').gen_spec.treesitter
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup {
      custom_textobjects = {
        f = spec_treesitter { -- function
          a = { '@function.outer', '@method_declaration.outer', '@method_definition.outer' },
          i = { '@function.inner', '@method_declaration.inner', '@method_definition.inner' },
        },
        i = spec_treesitter { -- loop or if
          a = { '@conditional.outer', '@loop.outer' },
          i = { '@conditional.inner', '@loop.inner' },
        },
      },
      n_lines = 500,
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    -- Note: if 'timeoutlen' is low enough to cause occasional usage of |s| key
    -- (that deletes character under cursor), disable it with the following call:
    vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')
    require('mini.surround').setup()

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim

    require('mini.starter').setup()

    local map_ai_move = function(lhs, textobject_id, direction, desc)
      local rhs = function()
        MiniAi.move_cursor('left', 'a', textobject_id, { search_method = direction })
      end
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, rhs, { desc = desc })
    end

    -- Instead of `'f'` use id of textobject you'd like to move.
    -- For more info see `:h MiniAi.move_cursor()`.
    map_ai_move('[m', 'f', 'cover_or_prev', 'Jump to prev function')
    map_ai_move(']m', 'f', 'cover_or_next', 'Jump to next function')
  end,
}
