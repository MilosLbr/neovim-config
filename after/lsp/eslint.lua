return {
  on_init = function(client)
    client.config.settings.workingDirectory = { directory = client.config.root_dir }
  end,
}
