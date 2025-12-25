return {
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      -- list of servers for mason to install
      ensure_installed = {
        'angularls',
        'csharp_ls',
        'css_variables',
        'cssls',
        'cssmodules_ls',
        'eslint',
        'html',
        'lua_ls',
        'ts_ls',
      },
    },
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = {
          ui = {
            icons = {
              package_installed = '✓',
              package_pending = '➜',
              package_uninstalled = '✗',
            },
          },
        },
      },
      'neovim/nvim-lspconfig',
    },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
      ensure_installed = {
        'prettierd', -- prettier formatter
        'stylua', -- lua formatter
        'black', -- python formatter
        'pylint',
        'eslint_d',
      },
    },
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
}
