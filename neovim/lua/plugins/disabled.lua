-- Disable plugins that are not needed
---@type LazySpec
return {
  -- Disable package-info (pulled in by astrocommunity.pack.typescript)
  -- Defined here (plugins/) so it overrides the community pack import
  { "vuki656/package-info.nvim", enabled = false },

  -- Disabled: migrated to conform.nvim (formatting) + nvim-lint (linting)
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
}
