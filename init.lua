--[[

  - Lua Tutorial
  - https://learnxinyminutes.com/docs/lua/

  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html

--]]

-- Get the directory of the current script and set the package path
local scriptPath = debug.getinfo(1).source:match("@?(.*[\\/])")
package.path = scriptPath .. "?.lua;" .. package.path

--  NOTE: Setting the leader key must happen before plugins are required (otherwise plugins will use wrong
--  leader)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- [[ Enter plugins into list to load ]]
pluginsToLoad = {
  "lua.vim-fugitiveConfig",
  "lua.vim-rhubarbConfig",
  "lua.vim-sleuthConfig",
  "lua.nvim-lspconfigConfig",
  "lua.commentConfig",
  "lua.nvim-cmpConfig",
  "lua.which-keyConfig",
  "lua.gitsignsConfig",
  "lua.moonbowConfig",
  --"lua.gruvboxConfig",
  "lua.lualineConfig",
  "lua.telescopeConfig",
  "lua.nvim-treesitterConfig",
  "lua.hopConfig",
  "lua.toggletermConfig",
  "lua.nuiConfig",
  "lua.plenaryConfig",
  "lua.nvim-web-deviconsConfig",
  "lua.lsp-inlayhintsConfig",
  "lua.neo-treeConfig",
}

for i = 1, #pluginsToLoad do
  require(pluginsToLoad[i])
end

-- [[ Configure lazy config and setup the plugins to load ]]
require("lua.lazyConfig").setup(pluginsToLoad)

-- [[ Configure vim options ]]
require("lua.vimOptions")

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print "Not a git repository. Searching on current working directory"
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require("telescope.builtin").live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

local function telescope_live_grep_open_files()
  require("telescope.builtin").live_grep {
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  }
end

-- Enable telescope project if installed
require("telescope").load_extension("project")

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require("nvim-treesitter.configs").setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      "c",
      "cpp",
      "go",
      "lua",
      "python",
      "rust",
      "tsx",
      "javascript",
      "typescript",
      "vimdoc",
      "vim",
      "bash" },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
    modules = {},
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<c-space>",
        node_incremental = "<c-space>",
        scope_incremental = "<c-s>",
        node_decremental = "<M-space>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>lr", vim.lsp.buf.rename, "[L]SP [R]ename")
  nmap("<leader>a", vim.lsp.buf.code_action, "Code [A]ction")
  nmap("<leader>lf", vim.lsp.buf.format, "[L]sp [F]ormat")

  nmap("<leader><leader>", vim.lsp.buf.definition, "Goto Definition (gd alternate)")
  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  --nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

  nmap("<leader>d", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<leader>D", vim.lsp.buf.signature_help, "Signature Documentation")


  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })

  -- don't do semantic tokens highlighting
  client.server_capabilities.semanticTokensProvider = nil
end

-- document existing key chains
require("which-key").register {
  ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
  ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
  ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
  ["<leader>h"] = { name = "Git [H]unk", _ = "which_key_ignore" },
  ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
  ["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
  ["<leader>t"] = { name = "[T]oggle Terminal", _ = "which_key_ignore" },
  ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
}

-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require("which-key").register({
  ["<leader>"] = { name = "VISUAL <leader>" },
  ["<leader>h"] = { "Git [H]unk" },
}, { mode = "v" })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("mason-lspconfig").setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { "html", "twig", "hbs"} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { "missing-fields" } },
    },
  },
}

-- Setup neovim lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require "mason-lspconfig"

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require("lspconfig")[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-----------------------------------------

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require "cmp"
local luasnip = require "luasnip"
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = "menu,menuone,noinsert",
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete {},
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
  },
}

-- gruvbox setup must be called before loading the colorscheme
-- require("gruvbox").setup({
--   undercurl = true,
--   underline = true,
--   bold = true,
--   italic = {
--     strings = false,
--     comments = true,
--     operators = false,
--     folds = true,
--   },
--   strikethrough = true,
--   invert_selection = false,
--   invert_signs = false,
--   invert_tabline = false,
--   invert_intend_guides = false,
--   inverse = true,  -- invert background for search, diffs, statuslines and errors
--   contrast = "",   -- can be "hard", "soft" or empty string
--   palette_overrides = {},
--   overrides = {},
--   dim_inactive = false,
--   transparent_mode = true,
-- })

-- moonbow setup must be called before loading the colorscheme
require("moonbow").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = true,
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true,
  contrast = "",
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = true,
})

vim.cmd("colorscheme moonbow")

-- [[Configure ToggleTerm]]
require("toggleterm").setup {
  size = 110,
  open_mapping = [[<C-\>]],
}

vim.keymap.set({ "n", "v" }, "<leader>t", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "[T]oggleTerm" })
vim.keymap.set("t", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "[T]oggleTerm" })
vim.keymap.set("t", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neotr[ee]" })
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Focus on window to left" })
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Focus on window to right" })
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Focus on window above" })
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Focus on window below" })

-- [[Configure Hop]]
require("hop").setup()
vim.keymap.set({ "n", "v" }, "f", "<cmd>HopWord<cr>", { silent = true })
vim.keymap.set({ "n", "v" }, "F", "<cmd>HopPattern<cr>", { silent = true })

-- [[Configure Inlay-Hints]]
require("lsp-inlayhints").setup()

vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_inlayhints",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("lsp-inlayhints").on_attach(client, bufnr, false)
  end,
})

local inlay_enabled = true

vim.keymap.set("n", "<leader>lh", function()
  if inlay_enabled then
    require("lsp-inlayhints").reset()
  else
    require("lsp-inlayhints").show()
  end
  inlay_enabled = not inlay_enabled
end, { desc = "LSP: Inlay-[H]ints" })

-- [[ Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fF", require("telescope.builtin").git_files, { desc = "[F]ind [F]iles (just git files)" })
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fw", require("telescope.builtin").grep_string, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>fr", require("telescope.builtin").resume, { desc = "[F]ind [R]esume" })
vim.keymap.set("n", "<leader>fs", require("telescope.builtin").builtin, { desc = "[F]ind [S]elect Telescope" })
vim.keymap.set("n", "<leader>f/", telescope_live_grep_open_files, { desc = "[F]ind [/] in Open Files" })
vim.keymap.set("n", "<leader>fG", ":LiveGrepGitRoot<cr>", { desc = "[S]earch by [G]rep on Git Root" })

vim.keymap.set("n", "<c-p>", require("telescope").extensions.project.project, { desc = "Telescope [P]roject" })

-- [[Configure Neotree]]
vim.keymap.set({ "n", "v" }, "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neotr[ee]" })

-- Easier Navigate to End and Beginning of words of line
vim.keymap.set({ "n", "v" }, "B", "^", { silent = true, desc = "Goto end of line" })
vim.keymap.set({ "n", "v" }, "^", "<Nop>", { silent = true, desc = "no-op ^" })
vim.keymap.set({ "n", "v" }, "E", "$", { silent = true, desc = "Goto beginning of line" })
vim.keymap.set({ "n", "v" }, "$", "<Nop>", { silent = true, desc = "no-op $" })

-- Remap for dealing with word wrap, stay in column
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Keep the cursor at the current column when squashing lines
vim.keymap.set("n", "J", "mzJ`z", { silent = true, desc = "Squash lines" })

-- Move whole lines up and down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { silent = true, desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { silent = true, desc = "Move line up" })

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selected lines down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selected lines up" })

-- Replay the q macro. quick so "qq" to start macro and "space" to play
vim.keymap.set("n", "<Space>", "@q", { silent = true, desc = "Replay q macro" })

-- paste over selection without copying selection
vim.keymap.set("v", "p", '"_dP', { silent = true, desc = "Paste without copy" })

-- Window Moving
vim.keymap.set({ "n", "v" }, "<C-h>", "<cmd>wincmd h<cr>", { desc = "Move to window left" })
vim.keymap.set({ "n", "v" }, "<C-j>", "<cmd>wincmd j<cr>", { desc = "Move to window down" })
vim.keymap.set({ "n", "v" }, "<C-k>", "<cmd>wincmd k<cr>", { desc = "Move to window up" })
vim.keymap.set({ "n", "v" }, "<C-l>", "<cmd>wincmd l<cr>", { desc = "Move to window right" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
