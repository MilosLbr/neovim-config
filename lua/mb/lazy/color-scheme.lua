return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    -- 'folke/tokyonight.nvim',
    'Mofiqul/vscode.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      require('vscode').setup {
        group_overrides = {
          -- global
          ['@lsp.type.enum'] = { fg = '#b8d7a3' },
          ['@lsp.type.enumMember'] = { fg = '#dcdcdc' },
          -- c-sharp
          ['@lsp.type.property.cs'] = { fg = '#dcdcdc' },
          ['@lsp.type.field.cs'] = { fg = '#dcdcdc' },
          ['@lsp.type.interface.cs'] = { fg = '#b8d7a3' },
          ['@lsp.type.namespace.cs'] = { fg = '#dcdcdc' },
          ['@lsp.type.keyword.cs'] = { link = 'NONE' },
          ['@keyword.import.c_sharp'] = { link = '@keyword' },
          -- typescript
          ['@lsp.typemod.variable.readonly.typescript'] = { link = 'NONE' },
          ['@lsp.typemod.property.readonly.typescript'] = { link = 'NONE' },
        },
      }

      vim.cmd [[colorscheme vscode]]

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },
}
