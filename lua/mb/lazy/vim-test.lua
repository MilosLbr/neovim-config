return {
  'vim-test/vim-test',
  config = function()
    vim.g['test#csharp#runner'] = 'dotnettest'
    vim.g['test#strategy'] = 'neovim'
    vim.g['test#neovim#start_normal'] = 1 -- open terminal in normal mode (default is insert)

    local function debug_test_strategy(cmd)
      vim.cmd 'botright new'
      vim.cmd 'resize 10'

      local dap = require 'dap'
      local attached = false

      vim.fn.jobstart(cmd, {
        term = true,
        env = { VSTEST_HOST_DEBUG = '1' },
        on_stdout = function(_, data, _)
          if attached or not data then
            return
          end
          for _, line in ipairs(data) do
            local pid = line:match 'Process Id:%s*(%d+)'
            if pid then
              attached = true
              vim.schedule(function()
                vim.notify('Found testhost PID ' .. pid .. ', attaching debugger...', vim.log.levels.INFO)
                dap.run {
                  type = 'coreclr',
                  request = 'attach',
                  processId = tonumber(pid),
                }
              end)
              break
            end
          end
        end,
      })
    end

    vim.g['test#custom_strategies'] = { debug = debug_test_strategy }

    local keymap = vim.keymap

    local function test_cmd(cmd)
      return function()
        vim.cmd 'wa'
        vim.cmd(cmd)
        vim.cmd 'normal! G'
      end
    end

    keymap.set('n', '<leader>tn', test_cmd 'TestNearest', { desc = 'Run the nearest test' })
    keymap.set('n', '<leader>tf', test_cmd 'TestFile', { desc = 'Run all the tests in the current file' })
    keymap.set('n', '<leader>ts', test_cmd 'TestSuite', { desc = 'Run the entire test suite' })
    keymap.set('n', '<leader>tl', test_cmd 'TestLast', { desc = 'Re-run the last test' })
    keymap.set('n', '<leader>tv', ':TestVisit<CR>', { desc = 'Jump to the last file' })

    keymap.set('n', '<leader>tD', function()
      vim.cmd 'wa'
      vim.g['test#strategy'] = 'debug'
      vim.cmd 'TestNearest'
      vim.g['test#strategy'] = 'neovim'
    end, { desc = 'Debug the nearest test' })
  end,
}
