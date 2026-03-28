return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map
          
          -- Buffer navigation
          ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
          
          -- Buffer management
          ["<Leader>bd"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Close buffer from tabline",
          },
          
          -- Quick quit
          ["q"] = { ":quit<cr>", desc = "Quit buffer" },

          -- CodeCompanion
          ["<Leader>ic"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle AI chat" },
          ["<Leader>ia"] = { "<cmd>CodeCompanionActions<cr>",     desc = "AI actions" },
        },
        v = {
          ["<Leader>ia"] = { "<cmd>CodeCompanionActions<cr>",  desc = "AI actions" },
          ["<Leader>ic"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add to AI chat" },

          -- Copy selection with file path and line numbers (useful for sharing code snippets)
          ["<Leader>cc"] = {
            function()
              local start_line = vim.fn.line "v"
              local end_line = vim.fn.line "."
              if start_line > end_line then start_line, end_line = end_line, start_line end
              local lines = vim.fn.getline(start_line, end_line)
              local file_path = vim.fn.expand "%:."
              local output = string.format("File: %s (Lines %d-%d)\n```\n", file_path, start_line, end_line)
              output = output .. table.concat(lines, "\n") .. "\n```"
              vim.fn.setreg("+", output)
              vim.notify("Copied to clipboard with metadata!", vim.log.levels.INFO)
            end,
            desc = "Copy selection with file and line numbers",
          },
        },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
}
