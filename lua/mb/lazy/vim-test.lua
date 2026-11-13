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
      local buf = vim.api.nvim_get_current_buf()
      local timer = assert(vim.uv.new_timer())
      local function stop()
        if not timer:is_closing() then
          timer:stop()
          timer:close()
        end
      end

      vim.fn.jobstart(cmd, {
        term = true,
        env = { VSTEST_HOST_DEBUG = '1' },
        on_exit = function()
          vim.schedule(stop)
        end,
      })

      -- On Windows the terminal's raw output is ConPTY redraw sequences, so
      -- scan the rendered terminal buffer for the testhost PID instead.
      local deadline = vim.uv.now() + 120000
      timer:start(200, 200, vim.schedule_wrap(function()
        if timer:is_closing() then
          return
        end
        if not vim.api.nvim_buf_is_valid(buf) or vim.uv.now() > deadline then
          return stop()
        end
        for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
          local pid = line:match 'Process Id:%s*(%d+)'
          if pid then
            stop()
            vim.notify('Found testhost PID ' .. pid .. ', attaching debugger...', vim.log.levels.INFO)
            dap.run {
              type = 'coreclr',
              name = 'Attach to test host ' .. pid,
              request = 'attach',
              processId = tonumber(pid),
            }
            return
          end
        end
      end))
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
      vim.cmd 'TestNearest -strategy=debug'
    end, { desc = 'Debug the nearest test' })
  end,
}
