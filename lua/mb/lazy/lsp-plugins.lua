return {
  -- Mason: portable package manager for LSP servers, formatters, linters, and DAP adapters.
  -- Installs and manages external tooling in a consistent way across platforms,
  -- independent of system package managers.
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
      registries = {
        'github:Crashdummyy/mason-registry',
        'github:mason-org/mason-registry',
      },
    },
  },

  -- Mason-lspconfig: bridges mason + lspconfig
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      {
        'neovim/nvim-lspconfig',
        dependencies = { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
      },
    },
    opts = {
      ensure_installed = {
        'angularls',
        -- 'csharp_ls',
        'css_variables',
        'cssls',
        'cssmodules_ls',
        'eslint',
        'html',
        'lua_ls',
        'ts_ls',
      },
    },
  },

  -- Mason-tool-installer: auto-install formatters, linters, etc.
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'prettierd',
        'stylua',
        'black',
        'pylint',
        'eslint_d',
        'roslyn',
      },
    },
  },

  -- Roslyn: C# language server (needs its own plugin to start)
  {
    'seblyng/roslyn.nvim',
    ft = 'cs',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {},
  },
}
