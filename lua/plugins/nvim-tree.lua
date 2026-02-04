return {
  "nvim-tree/nvim-tree.lua",

  opts = {
    -- Keep the tree focused on the file in the current buffer
    update_focused_file = {
      enable = true,
    },

    -- Sort files case-sensitively
    sort = {
      sorter = "case_sensitive",
    },

    -- Auto-resize tree width based on content
    view = {
      adaptive_size = true,
    },

    -- Visually group empty directories together
    renderer = {
      group_empty = true,
    },

    -- Hide dotfiles (.*) in the tree
    filters = {
      dotfiles = true,
    },

    -- Close the tree after opening a file
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
  },
}

