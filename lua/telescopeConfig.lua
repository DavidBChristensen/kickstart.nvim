-- Fuzzy Finder (files, lsp, etc)

local M = {}

table.insert(PluginsToLoad, {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      -- build = "make",

      build =
      "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      cond = function()
        return vim.fn.executable "make" == 1
      end,
    },
  },
}
)

-- Telescope project extensions
table.insert(PluginsToLoad, { "nvim-telescope/telescope-project.nvim" })
table.insert(PluginsToLoad, { "nvim-telescope/telescope-file-browser.nvim" }

)


return M
