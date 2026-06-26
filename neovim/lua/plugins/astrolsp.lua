-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = false,        -- codelens has limited vtsls support and adds overhead in AFM
      inlay_hints = false,     -- enable/disable inlay hints on start
      semantic_tokens = true,  -- enable/disable semantic token highlighting
    },
    formatting = {
      format_on_save = {
        enabled = true,
      },
      timeout_ms = 1000,
    },
    ---@diagnostic disable: missing-fields
    config = {
      -- vtsls: multi-workspace config for AFM monorepo — VSCode-like behaviour with 8GB limit
      vtsls = {
        settings = {
          typescript = {
            tsserver = {
              maxTsServerMemory = 8192,
              useSyntaxServer = "auto",
              experimental = {
                enableProjectDiagnostics = false,
              },
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
              autoImportFileExcludePatterns = {
                "**/node_modules/**",
                "**/.git/**",
                "**/dist/**",
                "**/build/**",
                "**/.next/**",
                "**/coverage/**",
              },
            },
            workspaceSymbols = {
              scope = "currentProject",
              excludeLibrarySymbols = true,
            },
            updateImportsOnFileMove = { enabled = "always" },
            disableAutomaticTypeAcquisition = true,
          },
          javascript = {
            preferences = {
              includePackageJsonAutoImports = "auto",
              autoImportFileExcludePatterns = {
                "**/node_modules/**",
                "**/.git/**",
                "**/dist/**",
                "**/build/**",
              },
            },
            updateImportsOnFileMove = { enabled = "always" },
          },
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
                entriesLimit = 2000,
              },
            },
          },
        },
      },
    },
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
  },
}
