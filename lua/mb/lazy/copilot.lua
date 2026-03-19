return {
  'zbirenbaum/copilot.lua',
  config = function()
    require('copilot').setup {
      panel = {
        auto_refresh = true,
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = '<M-k>',
          accept_word = '<M-w>',
          accept_line = '<M-l>',
        },
      },
    }
  end,
}
