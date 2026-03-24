return {
  'olimorris/codecompanion.nvim',
  version = '^19.0.0',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  init = function()
    local group = vim.api.nvim_create_augroup('CodeCompanionFidget', { clear = true })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionRequestStarted',
      group = group,
      callback = function(e)
        e.data.handle = require('fidget.progress').handle.create {
          title = '🤖' .. ' CodeCompanion',
          message = ' Thinking...',
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
    display = {
      chat = {
        show_header_separator = true,
        show_references = true,
      },
      diff = {
        provider = 'default',
      },
    },
    strategies = {
      chat = {
        adapter = 'copilot',
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
  },
}
