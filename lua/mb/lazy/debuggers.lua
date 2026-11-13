return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    {
      'jay-babu/mason-nvim-dap.nvim',
      dependencies = { 'williamboman/mason.nvim' },
      opts = {
        ensure_installed = { 'debugpy', 'netcoredbg' },
        automatic_installation = true,
      },
    },
    'mfussenegger/nvim-dap-python',
    'theHamsta/nvim-dap-virtual-text',
  },

  config = function()
    vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })

    local dap, dapui, dap_virtual_text = require 'dap', require 'dapui', require 'nvim-dap-virtual-text'
    dapui.setup()
    dap_virtual_text.setup {}

    -- auto open/close dap-ui on dap events
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- keymaps
    vim.keymap.set('n', '<F5>', function()
      dap.continue()
    end, { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<F10>', function()
      dap.step_over()
    end, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F11>', function()
      dap.step_into()
    end, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F12>', function()
      dap.step_out()
    end, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<S-F11>', function()
      dap.step_out()
    end, { desc = 'Debug: Step Out (Shift+F11)' })
    vim.keymap.set('n', '<F9>', function()
      dap.toggle_breakpoint()
    end, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Condition: ')
    end, { desc = 'Debug: Conditional Breakpoint' })
    vim.keymap.set('n', '<leader>dr', function()
      dap.repl.open()
    end, { desc = 'Debug: Open REPL' })
    vim.keymap.set('n', '<leader>dl', function()
      dap.run_last()
    end, { desc = 'Debug: Run Last' })
    vim.keymap.set('n', '<C-F10>', function()
      dap.run_to_cursor()
    end, { desc = 'Debug: Run to Cursor' })
    vim.keymap.set('n', '<C-S-F10>', function()
      dap.goto_() -- go to cursor
    end, { desc = 'Debug: Go to Cursor' })
    vim.keymap.set('n', '<S-F9>', function()
      dapui.eval(nil, { enter = true })()
    end, { desc = 'Debug: Evaluate Expression' })

    -- python
    require('dap-python').setup()

    -- dotnet
    local function get_build_target()
      local current_file = vim.api.nvim_buf_get_name(0)
      if current_file ~= '' then
        local csproj = vim.fs.find(function(name)
          return name:match '%.csproj$'
        end, { upward = true, path = vim.fs.dirname(current_file) })[1]
        if csproj then
          return csproj
        end
      end

      local sln = vim.fs.find(function(name)
        return name:match '%.sln$'
      end, { path = vim.fn.getcwd() })[1]
      if sln then
        return sln
      end

      return ''
    end

    local function get_dll_dir()
      local target = get_build_target()
      local base = (target ~= '' and target:match '%.csproj$') and vim.fs.dirname(target) or vim.fn.getcwd()
      local debug_dir = base .. '/bin/Debug/'
      local tfm_dirs = vim.fn.glob(debug_dir .. 'net*/', false, true)
      if #tfm_dirs > 0 then
        table.sort(tfm_dirs, function(a, b)
          local va = tonumber(a:match 'net(%d+)') or 0
          local vb = tonumber(b:match 'net(%d+)') or 0
          return va < vb
        end)
        return (tfm_dirs[#tfm_dirs]:gsub('\\', '/'))
      end
      return debug_dir
    end

    local no_build_config = {
      type = 'coreclr',
      name = 'Launch App (no build)',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to dll: ', get_dll_dir(), 'file')
      end,
    }

    vim.keymap.set('n', '<leader>dd', function()
      local target = get_build_target()
      local target_name = target ~= '' and vim.fs.basename(target) or 'solution'
      vim.notify('Building ' .. target_name .. '...', vim.log.levels.INFO)
      local cmd = target ~= '' and ('dotnet build "' .. target .. '"') or 'dotnet build'
      vim.fn.jobstart(cmd, {
        on_exit = function(_, return_code)
          if return_code == 0 then
            vim.notify('Build OK (' .. target_name .. '), starting debugger...', vim.log.levels.INFO)
            vim.schedule(function()
              dap.run(no_build_config)
            end)
          else
            vim.notify('Build failed with exit code ' .. return_code, vim.log.levels.ERROR)
          end
        end,
      })
    end, { desc = 'Debug: Build and Continue' })

    dap.adapters.coreclr = {
      type = 'executable',
      command = vim.fn.stdpath 'data'
        .. '/mason/packages/netcoredbg/netcoredbg/netcoredbg'
        .. (vim.fn.has 'win32' == 1 and '.exe' or ''),
      args = { '--interpreter=vscode' },
    }

    dap.adapters.remote_coreclr = {
      type = 'server',
      host = '127.0.0.1',
      port = 4711,
    }

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Launch App (build first)',
        request = 'launch',
        program = function()
          local target = get_build_target()
          local cmd = target ~= '' and ('!dotnet build "' .. target .. '"') or '!dotnet build'
          vim.cmd(cmd)
          if vim.v.shell_error ~= 0 then
            vim.notify('Build failed', vim.log.levels.ERROR)
            return dap.ABORT
          end
          return vim.fn.input('Path to dll: ', get_dll_dir(), 'file')
        end,
      },
      no_build_config,
      {
        type = 'coreclr',
        name = 'Attach to process',
        request = 'attach',
        processId = function()
          return require('dap.utils').pick_process()
        end,
      },
      {
        type = 'coreclr',
        name = 'Attach to test host',
        request = 'attach',
        processId = function()
          return require('dap.utils').pick_process { filter = 'testhost' }
        end,
      },
      {
        type = 'remote_coreclr',
        name = 'Remote attach',
        request = 'attach',
        processId = function()
          return tonumber(vim.fn.input 'Remote PID: ')
        end,
        pathMappings = function()
          local remote_root = vim.fn.input 'Remote root: '
          return {
            {
              localRoot = vim.fn.getcwd(),
              remoteRoot = remote_root,
            },
          }
        end,
      },
      {
        type = 'remote_coreclr',
        name = 'Remote launch',
        request = 'launch',
        program = function()
          return vim.fn.input 'Remote DLL path: '
        end,
        cwd = function()
          return vim.fn.input 'Remote working directory: '
        end,
      },
    }
  end,
}
