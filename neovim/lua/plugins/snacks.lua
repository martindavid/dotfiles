return {
  "folke/snacks.nvim",
  specs = {
    {
      "AstroNvim/astrolsp",
      opts = {
        mappings = {
          n = {
            -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
            gD = {
              function() require("snacks").picker.lsp_declarations() end,
              desc = "Goto Declaration",
              cond = "textDocument/declaration",
            },
            gd = {
              function() require("snacks").picker.lsp_definitions() end,
              desc = "Goto Definition",
              cond = "textDocument/definition",
            },
            gI = {
              function() require("snacks").picker.lsp_implementations() end,
              desc = "Goto Implementation",
              cond = "textDocument/implementation",
            },
            gy = {
              function() require("snacks").picker.lsp_type_definitions() end,
              desc = "Goto Type Definitions",
              cond = "textDocument/typeDefinition",
            },
            ["<Leader>lR"] = {
              function() require("snacks").picker.lsp_references() end,
              desc = "Goto Reference",
              cond = "textDocument/references",
            },
            ["<Leader>lG"] = {
              function() require("snacks").picker.lsp_workspace_symbols() end,
              desc = "Workspace Symbols",
            },
          },
        },
      },
    },
  },
  ---@type snacks.Config
  opts = {
    picker = {
      formatters = {
        file = {
          truncate = 80,
        },
      },
      -- Configure file search to include all files
      sources = {
        files = {
          -- Use fd with custom ignore patterns
          cmd = "fd",
          args = {
            "--type", "f",
            "--hidden",  -- Include hidden files
            "--exclude", "node_modules",
            "--exclude", ".git",
            "--exclude", "dist",
            "--exclude", "build",
          },
        },
        grep = {
          -- Use ripgrep for grep
          cmd = "rg",
          args = {
            "--color=never",
            "--line-number",
            "--column",
          },
        },
      },
    },
  },
}
