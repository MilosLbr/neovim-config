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
    vim.g.codecompanion_log_level = 'TRACE'
    local group = vim.api.nvim_create_augroup('CodeCompanionFidget', { clear = true })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionRequestStarted',
      group = group,
      callback = function(e)
        local adapter = e.data.adapter
        local model = adapter.model
        local message = string.format('🤖 %s', adapter.formatted_name)
        if model then
          message = string.format('%s (%s)', message, model)
        end
        e.data.handle = require('fidget.progress').handle.create {
          title = ' Thinking...',
          message = message,
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

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionChatModel',
      group = group,
      callback = function(e)
        if not e.data.model then
          return
        end
        local chat = require('codecompanion').buf_get_chat(e.data.bufnr)
        if chat then
          chat.adapter.active_model = e.data.model
        end
      end,
    })
  end,

  opts = {
    adapters = {
      acp = {
        extend = {
          opencode = {
            defaults = {
              model = 'github-copilot/claude-sonnet-4.6',
              mcpServers = 'inherit_from_config',
            },
          },
        },
      },
    },
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
      opts = {
        chat = {
          autoload = function()
            local cwd = vim.fn.getcwd()
            local github_exists = vim.uv.fs_stat(cwd .. '/.github') ~= nil
            if github_exists then
              return { 'default', 'project_specific_copilot_rules' }
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
    interactions = {
      chat = {
        adapter = {
          name = 'copilot',
          model = 'claude-sonnet-4.6',
        },
        roles = {
          llm = function(adapter)
            local details = adapter.formatted_name
            if adapter.active_model then
              details = string.format('%s, %s', details, adapter.active_model)
            end
            return string.format('CodeCompanion (%s)', details)
          end,
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
        tools = {
          ['read_file'] = {
            opts = {
              require_approval_before = false,
            },
          },
          ['file_search'] = {
            opts = {
              require_approval_before = false,
            },
          },
          ['get_changed_files'] = {
            opts = {
              require_approval_before = false,
            },
          },
          ['get_diagnostics'] = {
            opts = {
              require_approval_before = false,
            },
          },
          ['grep_search'] = {
            opts = {
              require_approval_before = false,
            },
          },
          ['run_command'] = {
            opts = {
              require_approval_before = function(tool, _tools)
                local cmd = tool.args.cmd
                local auto_approved = {
                  'rg ',
                  'dir',
                  'cat ',
                  'type ',
                  'ls ',
                  'find ',
                  'findstr ',
                  'git status',
                  'git log',
                  'git diff',
                  'git show',
                  'git branch',
                  'echo ',
                  'which ',
                  'where ',
                  'Get-ChildItem ',
                  'Get-Content ',
                }
                for _, prefix in ipairs(auto_approved) do
                  if vim.startswith(cmd, prefix) then
                    return false
                  end
                end
                return true
              end,
            },
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
          title_generation_opts = {
            adapter = 'copilot',
            model = 'claude-haiku-4.5',
          },
          summary = {
            create_summary_keymap = 'gm',
          },
        },
      },
    },
  },
}
