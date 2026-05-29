return {
  'sindrets/diffview.nvim',
  config = function()
    require('diffview').setup {
      enhanced_diff_hl = true,
    }

    local function set_diff_hl()
      -- Base diff groups
      vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#14301b' })
      vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#3a1515' })
      vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#1b1b1b' })
      vim.api.nvim_set_hl(0, 'DiffText', { bg = '#264f78' })

      -- Diffview groups
      vim.api.nvim_set_hl(0, 'DiffviewDiffAdd', { link = 'DiffAdd' })
      vim.api.nvim_set_hl(0, 'DiffviewDiffDelete', { link = 'DiffDelete' })
      vim.api.nvim_set_hl(0, 'DiffviewDiffChange', { link = 'DiffChange' })
      vim.api.nvim_set_hl(0, 'DiffviewDiffText', { link = 'DiffText' })
      vim.api.nvim_set_hl(0, 'DiffviewDiffAddAsDelete', { bg = '#3a1515' })
      vim.api.nvim_set_hl(0, 'DiffviewDiffDeleteDim', { bg = '#2a1010' })
    end

    set_diff_hl()

    vim.keymap.set('n', '<leader>do', ':DiffviewOpen<CR>', { desc = 'DiffviewOpen' })
    vim.keymap.set('n', '<leader>dc', ':DiffviewClose<CR>', { desc = 'DiffviewClose' })
  end,
}
