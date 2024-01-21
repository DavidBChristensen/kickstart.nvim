local M = {}

-- View options using `:help vim.o`

vim.o.background = "light"
vim.o.hlsearch = false
vim.wo.number = true
vim.o.mouse = "a"
vim.o.breakindent = true
vim.o.undofile = true
vim.wo.signcolumn = "yes"
vim.o.completeopt = "menuone,noselect" -- Set completeopt to have a better completion experience
vim.o.scrolloff = 8
vim.o.colorcolumn = "110"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.clipboard = "unnamedplus"
vim.o.relativenumber = false -- I have relative line numbers off when using hop
vim.o.wrap = false
vim.o.termguicolors = true
vim.o.timeout = true
vim.o.timeoutlen = 300

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

return M
