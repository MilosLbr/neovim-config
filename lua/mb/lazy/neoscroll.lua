return {
  'karb94/neoscroll.nvim',
  opts = {
    duration_multiplier = 0.2,
    hide_cursor = false,
    post_hook = function(info)
      if info == 'center-on-scroll' then
        vim.cmd 'normal! zz'
      end
    end,
  },
}
