if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(_, opts)
    if opts.mappings.n["<Leader>lR"] then
      opts.mappings.n["<Leader>lR"][1] = function() require("snacks").picker.lsp_references() end
    end
  end,
}
