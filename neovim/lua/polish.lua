-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Copy highlighted code with file path and line numbers
local function copy_with_metadata()
  local start_line = vim.fn.line "v"
  local end_line = vim.fn.line "."
  
  -- Ensure start_line is less than end_line
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  
  -- Get the selected lines
  local lines = vim.fn.getline(start_line, end_line)
  local file_path = vim.fn.expand "%:."
  
  -- Format the output with metadata
  local output = string.format("File: %s (Lines %d-%d)\n```\n", file_path, start_line, end_line)
  output = output .. table.concat(lines, "\n")
  output = output .. "\n```"
  
  -- Copy to system clipboard
  vim.fn.setreg("+", output)
  vim.notify("Copied to clipboard with metadata!", vim.log.levels.INFO)
end

-- Set up keybindings
vim.keymap.set("v", "<Leader>cc", copy_with_metadata, { noremap = true, silent = true, desc = "Copy selection with file and line numbers" })
