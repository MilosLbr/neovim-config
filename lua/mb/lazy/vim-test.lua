return {
  'vim-test/vim-test',
  config = function()
    vim.g['test#csharp#runner'] = 'dotnettest'
    vim.g['test#strategy'] = 'neovim'
    vim.g['test#neovim#start_normal'] = 1 -- open terminal in normal mode (default is insert)

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
  end,
}
