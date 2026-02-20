return {
  'zbirenbaum/copilot.lua',
  config = function()
    require('copilot').setup {
      panel = {
        auto_refresh = true,
        layout = {
          position = 'right',
        },
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = '<M-l>',
          accept_word = '<M-w>',
          accept_line = '<M-k>',
        },
      },
    }
  end,
}
