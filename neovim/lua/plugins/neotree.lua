return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    enable_git_status = false,
    enable_diagnostic = false,
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = false,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          ".git",
          ".DS_Store",
          "thumbs.db",
        },
        never_show = {},
      },
    },
    async_directory_scan = "always",
    window = {
      position = "left",
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function() require("neo-tree.command").execute { action = "close" } end,
      },
    },
  },
}
