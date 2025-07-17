local custom_providers = require "../custom/atlassian-avante" -- Path will be different for you most likely

-- Customize Mason

---@type LazySpec
return {
  "yetone/avante.nvim",
  opts = {
    provider = "atlgemini", -- atlgemini or atlopenai
    -- Add new providers to the empty table if you'd like to directly consume something else (e.g. ollama locally)
    providers = vim.tbl_deep_extend("force", {}, custom_providers),
  },
}
