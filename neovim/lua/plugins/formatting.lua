-- Formatting and linting via conform.nvim + nvim-lint
-- Replaces the deprecated none-ls (null-ls) approach

---@type LazySpec
return {
  -- Formatter: prettier for web filetypes
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      -- Single owner of format-on-save. lsp_format = "fallback" means: use prettier
      -- where configured, otherwise fall back to LSP formatting (e.g. lua_ls, gopls).
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
      },
      -- Only run prettier when a prettier config or package.json is present
      formatters = {
        prettier = {
          condition = function(_, ctx)
            return vim.fs.find(
              { "package.json", ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml" },
              { path = ctx.filename, upward = true }
            )[1] ~= nil
          end,
        },
      },
    },
  },

  -- Linter: eslint_d for JS/TS filetypes
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require "lint"

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          -- Only lint when an eslint config is present in the project
          local has_eslint = vim.fs.find(
            { "package.json", ".eslintrc.json", ".eslintrc.js", ".eslint.config.mjs", ".eslintrc.cjs" },
            { upward = true }
          )[1]
          if has_eslint then lint.try_lint() end
        end,
      })
    end,
  },
}
