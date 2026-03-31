-- See `:help vim.keymap.set()`
local keymap = vim.keymap.set

-- NOTE: Normal mode

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
keymap('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous [D]iagnostic message' })
keymap('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next [D]iagnostic message' })
keymap('n', ']e', function()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR, float = true }
end, { desc = 'Go to next [E]rror message' })
keymap('n', '[e', function()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR, float = true }
end, { desc = 'Go to previous [E]rror message' })
keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
keymap('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Save all
keymap('n', '<C-s>', ':wa<CR>', { noremap = false, silent = true })
keymap('i', '<C-s>', '<Esc>:wa<CR>', { noremap = false, silent = true })

-- Resize with arrows
keymap('n', '<C-Up>', ':resize -2<CR>', { silent = true })
keymap('n', '<C-Down>', ':resize +2<CR>', { silent = true })
keymap('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
keymap('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })

-- Navigate buffers
keymap('n', '<S-l>', ':bnext<CR>zz')
keymap('n', '<S-h>', ':bprevious<CR>zz')
keymap('n', '<A-0>', '<C-^>zz')

-- Center the view when navigating
keymap('n', 'G', 'Gzz')
keymap('n', '<C-o>', '<C-o>zz')
keymap('n', '<C-i>', '<C-i>zz')
keymap('n', '{', '{zz')
keymap('n', '}', '}zz')

-- Increment and decrement (decrement is <C-x> as is by default)
keymap('n', '<C-z>', '<C-a>', { desc = 'Increment number under cursor' })

-- Select all
keymap('n', '<C-a>', 'gg<S-v>G', { desc = 'Select all' })

-- Replace start of the line keymaps
keymap('n', '_', '0')
keymap('n', '0', '_')

-- NOTE: Insert mode

-- Press jk fast to exit insert mode
keymap('i', 'jk', '<ESC>')
keymap('i', 'kj', '<ESC>')

-- NOTE: Visual mode

-- Stay in indent mode
keymap('v', '<', '<gv^')
keymap('v', '>', '>gv^')

-- Move text up and down
keymap('n', '<A-j>', ':m .+1<CR>==')
keymap('n', '<A-k>', ':m .-2<CR>==')

-- Keep copied text after pasting instead of replacing the paste registry
keymap('v', 'p', '"_dP')

-- NOTE: Visual block mode

-- Move text up and down
keymap('x', 'K', ":m '<-2<CR>gv=gv")
keymap('x', 'J', ":m '>+1<CR>gv=gv")
keymap('x', '<A-j>', ":m '>+1<CR>gv=gv")
keymap('x', '<A-k>', ":m '<-2<CR>gv=gv")

local neoscroll = require 'neoscroll'
local keymaps = {
  ['<C-u>'] = function()
    neoscroll.scroll(-12, {
      duration = 100,
      info = 'center-on-scroll',
    })
  end,
  ['<C-d>'] = function()
    neoscroll.scroll(12, {
      duration = 100,
      info = 'center-on-scroll',
    })
  end,
}

local modes = { 'n', 'v', 'x' }
for key, func in pairs(keymaps) do
  keymap(modes, key, func)
end

keymap(
  { 'n', 'v' },
  '<localleader>cc',
  '<cmd>CodeCompanionChat Toggle<cr>',
  { noremap = true, silent = true, desc = 'Toggle Code Companion Chat' }
)
keymap(
  'v',
  'ga',
  '<cmd>CodeCompanionChat Add<cr>',
  { noremap = true, silent = true, desc = 'Add selection to Code Companion Chat' }
)
