return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
  },
  config = function()
    local focus_preview = function(prompt_bufnr)
      local action_state = require 'telescope.actions.state'
      local picker = action_state.get_current_picker(prompt_bufnr)
      local prompt_win = picker.prompt_win
      local previewer = picker.previewer
      local winid = previewer.state.winid
      local bufnr = previewer.state.bufnr
      vim.keymap.set('n', '<Tab>', function()
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
      end, { buffer = bufnr })
      vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))
    end

    local actions = require 'telescope.actions'
    local lga_actions = require 'telescope-live-grep-args.actions'
    local trouble = require 'trouble.sources.telescope'

    local default_lsp_picker_config = {
      show_line = false,
      include_current_line = false,
      include_declaration = false,
      layout_config = {
        preview_width = 0.5,
      },
    }

    require('telescope').setup {
      defaults = {
        dynamic_preview_title = true,
        layout_config = {
          width = 0.9,
        },
        file_ignore_patterns = { 'node_modules' },
        path_display = {
          'smart',
        },
        mappings = {
          n = {
            ['<Tab>'] = focus_preview,
            ['<C-q>'] = trouble.open,
            ['<A-q>'] = trouble.add,
            ['<CR>'] = actions.select_default + actions.center,
          },
          i = {
            ['<Tab>'] = focus_preview,
            ['<C-q>'] = trouble.open,
            ['<A-q>'] = trouble.add,
          },
        },
      },
      pickers = {
        lsp_references = default_lsp_picker_config,
        lsp_incoming_calls = default_lsp_picker_config,
        lsp_outgoing_calls = default_lsp_picker_config,
        lsp_definitions = default_lsp_picker_config,
        lsp_type_definitions = default_lsp_picker_config,
        lsp_implementations = default_lsp_picker_config,
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        live_grep_args = {
          disable_coordinates = true,
          auto_quoting = true,
          mappings = {
            n = {
              ['<Tab>'] = focus_preview,
            },
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
              ['<C-e>'] = lga_actions.quote_prompt { postfix = ' --iglob !**/*' },
            },
          },
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'live_grep_args')

    local builtin = require 'telescope.builtin'
    local extensions = require('telescope').extensions
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', extensions.live_grep_args.live_grep_args, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
