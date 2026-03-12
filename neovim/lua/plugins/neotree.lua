return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Default configuration
    opts.enable_git_status = false
    opts.enable_diagnostics = false
    opts.enable_refresh_on_write = false
    
    opts.filesystem = opts.filesystem or {}
    opts.filesystem.scan_mode = "shallow"
    opts.filesystem.use_libuv_file_watcher = false
    -- Re-enabled: Follow current file when opening neo-tree
    opts.filesystem.follow_current_file = {
      enabled = true,
      leave_dirs_open = false,  -- Don't expand all parent dirs (faster)
    }
    -- CRITICAL: Disable all gitignore checking (new feature causing slowness)
    opts.filesystem.check_gitignore_in_search = false
    -- Removed bind_to_cwd = false to fix copy selector behavior
    
    opts.filesystem.window = opts.filesystem.window or {}
    opts.filesystem.window.mappings = {
      ["<leader>g"] = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" then 
          require("snacks").picker.grep { cwd = node.path } 
        end
      end,
      -- Custom mapping to copy vim's actual CWD
      ["yc"] = function()
        local cwd = vim.fn.getcwd()
        vim.fn.setreg("+", cwd)
        vim.notify("Copied CWD: " .. cwd, vim.log.levels.INFO)
      end,
    }
    
    opts.filesystem.filtered_items = {
      visible = true,  -- Show items, but hide specific ones
      show_hidden_count = false,
      hide_dotfiles = false,  -- Show dotfiles (you need to see them)
      hide_gitignored = false,  -- CRITICAL: Don't check gitignore (slow in AFM)
      hide_ignored = false,  -- CRITICAL: Don't check .ignore files (new slow feature)
      ignore_files = {},  -- CRITICAL: Disable .ignore file scanning
      hide_by_name = {
        ".git",
        ".DS_Store",
        "thumbs.db",
        "node_modules",
        "dist",
        "build",
        ".next",
        ".turbo",
        "coverage",
        ".yarn",
        ".cache",
        "__generated__",
      },
      never_show = {
        ".git",
        "node_modules",
      },
    }
    
    -- Check if in AFM - if yes, use "never", otherwise use "auto"
    local is_afm = vim.fn.getcwd():match("atlassian/afm") ~= nil
    opts.async_directory_scan = is_afm and "never" or "auto"
    
    opts.window = opts.window or {}
    opts.window.position = "left"
    
    opts.event_handlers = {
      {
        event = "file_opened",
        handler = function() require("neo-tree.command").execute { action = "close" } end,
      },
    }
    
    return opts
  end,
}
