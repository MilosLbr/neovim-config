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
        ensure_installed = { "debugpy" },
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
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- keymaps
    vim.keymap.set('n', '<F5>', function()
      dap.continue()
    end)
    vim.keymap.set('n', '<F10>', function()
      dap.step_over()
    end)
    vim.keymap.set('n', '<F11>', function()
      dap.step_into()
    end)
    vim.keymap.set('n', '<S-F11>', function()
      dap.step_out()
    end)
    vim.keymap.set('n', '<F9>', function()
      dap.toggle_breakpoint()
    end)
    vim.keymap.set('n', '<C-F10>', function()
      dap.run_to_cursor()
    end)
    vim.keymap.set('n', '<C-S-F10>', function()
      dap.goto_() -- go to cursor
    end)
    vim.keymap.set('n', '<S-F9>', function()
      dapui.eval(nil, { enter = true })()
    end)

    -- python
    require('dap-python').setup()

    -- dotnet
    -- local dotnet = require 'easy-dotnet'
    -- local debug_dll = nil
    --
    -- local function rebuild_project(co, path)
    --   local spinner = require('easy-dotnet.ui-modules.spinner').new()
    --   spinner:start_spinner 'Building'
    --   vim.fn.jobstart(string.format('dotnet build %s', path), {
    --     on_exit = function(_, return_code)
    --       if return_code == 0 then
    --         spinner:stop_spinner 'Built successfully'
    --       else
    --         spinner:stop_spinner('Build failed with exit code ' .. return_code, vim.log.levels.ERROR)
    --         error 'Build failed'
    --       end
    --       coroutine.resume(co)
    --     end,
    --   })
    --   coroutine.yield()
    -- end
    --
    -- local function ensure_dll()
    --   if debug_dll ~= nil then
    --     return debug_dll
    --   end
    --   local dll = dotnet.get_debug_dll()
    --   debug_dll = dll
    --   return dll
    -- end
    --
    -- local netcordbg_dir = vim.fn.stdpath 'data' .. '\\mason\\packages\\netcoredbg\\netcoredbg'
    --
    -- dap.adapters.coreclr = {
    --   type = 'executable',
    --   command = netcordbg_dir .. '\\netcoredbg.exe',
    --   args = { '--interpreter=vscode' },
    -- }
    --
    -- dap.configurations.cs = {
    --   {
    --     type = 'coreclr',
    --     name = 'launch - netcoredbg',
    --     request = 'launch',
    --     program = function()
    --       local dll = ensure_dll()
    --       local co = coroutine.running()
    --
    --       rebuild_project(co, dll.project_path)
    --       return dll.relative_dll_path
    --     end,
    --     cwd = function()
    --       local dll = ensure_dll()
    --       return dll.relative_project_path
    --     end,
    --   },
    -- }
    --
    -- dap.listeners.before['event_terminated']['easy-dotnet'] = function()
    --   debug_dll = nil
    -- end
  end,
}
