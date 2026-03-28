-- Overrides opts only from astrocommunity.completion.avante-nvim (community.lua).
-- Do NOT re-declare dependencies, build, or event here — Lazy.nvim merges by plugin name.
---@type LazySpec
return {
  "yetone/avante.nvim",
  opts = {
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-6",
        extra_request_body = {
          max_tokens = 8192,
          temperature = 0,
        },
      },
    },
  },
}
