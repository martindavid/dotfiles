-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start (TS/JS hints suppressed per-server below)
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- disabled: conform.nvim owns format-on-save (see formatting.lua)
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      
      -- Multi-workspace config for AFM monorepo - VSCode-like behavior with 8GB limit
      vtsls = {
        settings = {
          typescript = {
            -- Memory and performance settings
            tsserver = {
              maxTsServerMemory = 8192, -- 8GB limit (VSCode default is 3GB)
              -- Use syntax server for faster response (like VSCode)
              useSyntaxServer = "auto", -- Lightweight server for syntax ops
              -- Disable project-wide diagnostics to save memory
              experimental = {
                enableProjectDiagnostics = false, -- Don't analyze entire project upfront
              },
            },
            -- Disable heavy inlay hints (VSCode defaults)
            inlayHints = {
              enumMemberValues = { enabled = false },
              functionLikeReturnTypes = { enabled = false },
              parameterNames = { enabled = "none" },
              parameterTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
              variableTypes = { enabled = false },
            },
            -- Monorepo-specific optimizations
            preferences = {
              -- Key: Only scan current package for auto-imports (like VSCode "auto" mode)
              includePackageJsonAutoImports = "auto", -- Smart scanning, not "off"
              -- Exclude patterns to reduce scanning
              autoImportFileExcludePatterns = {
                "**/node_modules/**",
                "**/.git/**",
                "**/dist/**",
                "**/build/**",
                "**/.next/**",
                "**/coverage/**",
              },
            },
            -- Workspace-wide settings
            workspaceSymbols = {
              scope = "currentProject", -- Only current project, not all open projects
              excludeLibrarySymbols = true, -- Don't include node_modules in symbol search
            },
            updateImportsOnFileMove = { enabled = "always" },
            -- Disable automatic type acquisition to save memory
            disableAutomaticTypeAcquisition = true,
          },
          javascript = {
            inlayHints = {
              enumMemberValues = { enabled = false },
              functionLikeReturnTypes = { enabled = false },
              parameterNames = { enabled = "none" },
              parameterTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
              variableTypes = { enabled = false },
            },
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
            -- Use workspace TypeScript version (monorepo may have specific version)
            autoUseWorkspaceTsdk = true,
            -- Experimental: server-side optimizations
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true, -- Filter on server like VSCode
                entriesLimit = 2000, -- Reasonable limit (increased from 1000)
              },
            },
          },
        },
        -- MULTI-WORKSPACE: root at nearest package.json for monorepo support
        -- v6 async signature: root_dir receives (bufnr, callback)
        root_dir = function(bufnr, cb)
          cb(vim.fs.root(bufnr, "package.json"))
        end,
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- v6: the default handler uses the "*" key and receives only the server name
      -- ["*"] = function(server) vim.lsp.enable(server) end

      -- disable a server by setting its key to false
      -- rust_analyzer = false,
      -- custom handler example:
      -- pyright = function(server) vim.lsp.enable(server) end
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.enable(true, { bufnr = args.buf }) end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method("textDocument/semanticTokens/full") and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
