return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map
          -- mappings seen under group name "Buffer"
          ["q"] = { ":quit<cr>", desc = "Quit buffer" },
          -- ["<Leader>fw"] = {
          --   ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
          --   desc = "Live Grep with Args",
          -- },
          -- tables with the `name` key will be registered with which-key if it's installed
          -- quick save
          -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
}
