-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.completion.avante-nvim" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.motion.leap-nvim" },
  -- { import = "astrocommunity.git.blame-nvim" },
  -- { import = "astrocommunity.git.gitlinker-nvim" },
  -- { import = "astrocommunity.completion.copilot-cmp" },
  { import = "astrocommunity.utility.telescope-live-grep-args-nvim" },
  -- { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.recipes.heirline-nvchad-statusline" },
}
