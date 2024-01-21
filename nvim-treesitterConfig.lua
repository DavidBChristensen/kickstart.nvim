-- Highlight, edit, and navigate code

local M = {}

table.insert(pluginsToLoad,
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
  }
)

return M
