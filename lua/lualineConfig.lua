-- Shows a statusline
-- See `:help lualine.txt`

local M = {}

table.insert(PluginsToLoad, {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      icons_enabled = false,
      theme = "moonbow",
      component_separators = "|",
      section_separators = "",
    },
  },
}
)

return M
