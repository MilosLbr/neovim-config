return {
  filetypes = { 'htmlangular', 'typescript' },

  on_init = function(client)
    -- Disable formatting
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
    --
    -- -- Disable syntax highlighting
    client.server_capabilities.semantic_tokens_provider = nil

    -- Disable "Go to References"
    client.server_capabilities.referencesProvider = false
  end,
}
