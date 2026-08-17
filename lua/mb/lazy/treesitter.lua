return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      local parsers = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'vim',
        'vimdoc',
        'c_sharp',
        'javascript',
        'typescript',
      }

      -- install() already skips installed parsers, no manual check needed
      vim.defer_fn(function()
        require('nvim-treesitter').install(parsers)
      end, 0)

      -- Register parsers for their filetypes first
      -- (handles mismatches like c_sharp -> cs)
      local lang_ft_map = {
        c_sharp = 'cs',
      }
      for parser, ft in pairs(lang_ft_map) do
        vim.treesitter.language.register(parser, ft)
      end

      -- Build pattern list from installed/desired parsers
      -- (get_filetypes will include registered ones)
      local patterns = {}
      for _, parser in ipairs(parsers) do
        local fts = vim.treesitter.language.get_filetypes(parser)
        for _, ft in ipairs(fts) do
          table.insert(patterns, ft)
        end
      end

      -- Enable treesitter highlighting and indentation
      vim.api.nvim_create_autocmd('FileType', {
        pattern = patterns,
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if lang and pcall(vim.treesitter.language.add, lang) then
            vim.treesitter.start(args.buf, lang)
            if lang ~= 'ruby' then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    branch = 'main',
    config = function()
      local tsContext = require 'treesitter-context'

      vim.keymap.set('n', '<leader>tt', function()
        tsContext.toggle()
      end, { silent = true, desc = '[T]S context [t]oggle' })

      vim.keymap.set('n', '[x', function()
        tsContext.go_to_context(vim.v.count1)
      end, { silent = true, desc = 'Go to Conte[x]t' })
    end,
  },
}
