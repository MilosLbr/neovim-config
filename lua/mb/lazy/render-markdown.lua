return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
  opts = {
    preset = 'lazy',
    file_types = { 'markdown', 'copilot-chat', 'codecompanion' },
  },
}
