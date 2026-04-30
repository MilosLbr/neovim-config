return {
  'olimorris/codecompanion.nvim',
  version = '19.*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'MeanderingProgrammer/render-markdown.nvim',
    'ravitemer/codecompanion-history.nvim',
  },
  init = function()
    local group = vim.api.nvim_create_augroup('CodeCompanionFidget', { clear = true })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionRequestStarted',
      group = group,
      callback = function(e)
        e.data.handle = require('fidget.progress').handle.create {
          title = ' Thinking...',
          message = string.format('🤖 %s (%s)', e.data.adapter.formatted_name, e.data.adapter.model),
          lsp_client = { name = 'codecompanion' },
        }
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionRequestFinished',
      group = group,
      callback = function(e)
        if e.data.handle then
          e.data.handle.message = '🤖' .. '  Done'
          e.data.handle:finish()
        end
      end,
    })
  end,

  opts = {
    prompt_library = {
      markdown = {
        dirs = {
          vim.fs.joinpath(vim.fn.getcwd(), '/.codecompanion'),
        },
      },
    },
    rules = {
      project_specific_copilot_rules = {
        description = 'Project specific rule files for github copilot ',
        files = {
          '.github/**/*.instructions.md',
        },
      },
      project_specific_kilo_rules = {
        description = 'Project specific rule files for kilo code',
        files = {
          '.kilo/rules/**/*.md',
        },
      },
      opts = {
        chat = {
          autoload = function()
            local cwd = vim.fn.getcwd()
            local github_exists = vim.uv.fs_stat(cwd .. '/.github') ~= nil
            local kilo_exists = vim.uv.fs_stat(cwd .. '/.kilo') ~= nil
            if github_exists and kilo_exists then
              return { 'default', 'project_specific_copilot_rules' } -- when both exist, prioritize copilot rules
            else
              return { 'default', 'project_specific_copilot_rules', 'project_specific_kilo_rules' }
            end
          end,
        },
      },
    },
    display = {
      chat = {
        show_header_separator = true,
        show_references = true,
        window = {
          width = 0.4,
        },
      },
      diff = {
        provider = 'default',
      },
    },
    strategies = {
      chat = {
        adapter = {
          name = 'copilot',
          model = 'gpt-5-mini',
        },
        keymaps = {
          send = {
            modes = { n = '<CR>', i = '<C-s>' },
            callback = function(chat)
              chat:submit()
              vim.cmd 'stopinsert'
            end,
            description = 'Send and return to normal mode',
          },
        },
      },
      inline = {
        adapter = 'copilot',
      },
      cmd = {
        adapter = 'copilot',
      },
    },
    extensions = {
      history = {
        enabled = true,
        opts = {
          summary = {
            create_summary_keymap = 'gm',
          },
        },
      },
    },
  },
}
