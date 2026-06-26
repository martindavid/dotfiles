-- vtsls LSP configuration override
-- In AstroNvim v6, server-specific config can live here (`:h lsp-config`)
-- This sets the root_dir to find the nearest package.json (per-package in monorepo)
return {
  root_dir = function(fname)
    return vim.fs.root(fname, { "package.json" })
  end,
  on_init = function(client, initialize_result)
    if initialize_result.capabilities then
      client.server_capabilities.workspace = client.server_capabilities.workspace or {}
      client.server_capabilities.workspace.workspaceFolders = {
        supported = true,
        changeNotifications = true,
      }
    end
  end,
}
