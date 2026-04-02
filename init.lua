-- Basic Personal Settings
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.number = true
vim.o.relativenumber = true
vim.o.laststatus = 0
vim.opt_local.linebreak = true
vim.opt_local.smoothscroll = true
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true })

-- Lazy Nvim Setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
                vim.api.nvim_echo({
                        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                        { out, "WarningMsg" },
                        { "\nPress any key to exit..." },
                }, true, {})
                vim.fn.getchar()
                os.exit(1)
        end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
    spec =
        {
		-- Colour Scheme
		"datsfilipe/vesper.nvim",
		-- Indent Blank Lines
		"lukas-reineke/indent-blankline.nvim",
		-- Auto Pairs
		"windwp/nvim-autopairs",
		-- Comments
		"numToStr/Comment.nvim",
		-- NeoTree File Explorer
		{
				"nvim-neo-tree/neo-tree.nvim",
				dependencies =
				{
						"nvim-lua/plenary.nvim",
						"nvim-tree/nvim-web-devicons",
						"MunifTanjim/nui.nvim",
				},
		},
		-- Telescope
		"nvim-telescope/telescope.nvim",
		-- Auto Complete
		{
			'saghen/blink.cmp',
			dependencies = { 'rafamadriz/friendly-snippets' },
			version = '1.*',
		},
		-- LSP stuff
		{
			"neovim/nvim-lspconfig",
			dependencies = 
			{
				'saghen/blink.cmp',
			},
		},
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    install = { colorscheme = { "kanagawa" } },
    checker = { enabled = true },
    rocks = { enabled = false },
})

-- /////////////////////////vesper Colour Scheme options////////////////////////////
require('vesper').setup({
    transparent = false,
    italics = {
        comments = true,
        keywords = true, 
        functions = true,
        strings = true,
        variables = true,
    },
})

-- ///////////////////////////////Indent blank lines options////////////////////////
require("ibl").setup({
        indent = {char = "│"},
        scope = { enabled = true },
})

-- Auto Pairs options
require('nvim-autopairs').setup()

-- Comments options
require('Comment').setup()

-- Neotree options
require("neo-tree").setup({
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = false,
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
        },
    },
})
vim.api.nvim_set_keymap("n", "<leader>ee", ":Neotree toggle<CR>", { noremap = true, silent = true })

-- ////////////////////////////Telescope options/////////////////////////////////////
require("telescope").setup({
	pickers =
	{
		find_files = { theme = "dropdown" },
		live_grep = { theme = "dropdown" },
		current_buffer_fuzzy_find = { theme = "dropdown" },
	},
})

local tl_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tl_builtin.find_files)
vim.keymap.set("n", "<leader>fg",
	function()
		tl_builtin.live_grep({ cwd = vim.fn.getcwd() })
	end)

vim.keymap.set("n", "<leader>fs", tl_builtin.current_buffer_fuzzy_find)

-- ////////////////////////////////Auto Complete options///////////////////////////
require('blink.cmp').setup({
	keymap = { preset = 'super-tab' },

    appearance = {
		nerd_font_variant = 'mono'
    },
	

	sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

	signature = { enabled = true },

	fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- ////////////////////////////////LSP configurations//////////////////////////////
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd" }
})

local lspconfig = vim.lsp.config
local capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.start({
    name = "clangd",
    cmd = { "clangd" },
    root_dir = vim.fs.root(0, { "compile_commands.json", ".git" }),
    capabilities = capabilities,
})

-- //////////////////////////LSP Keybindings///////////////////////////////

local generic_layout = {
    layout_strategy = "flex",
    layout_config = {
        width = 0.7,
        height = 0.7,
        horizontal = { mirror = false, preview_cutoff = 20, preview_width = 0.5 },
        vertical   = { mirror = false, preview_cutoff = 20, preview_height = 0.5 },
    },
    previewer = true,
    jump_type = "never",
    sorter = require("telescope.config").values.generic_sorter(),
}

vim.keymap.set("n", "<leader>ld", function()
    tl_builtin.lsp_definitions(generic_layout)
end, { desc = "Telescope LSP Definitions" })

vim.keymap.set("n", "<leader>lt", function()
    tl_builtin.lsp_type_definitions(generic_layout)
end, { desc = "Telescope LSP Type Definitions" })

vim.keymap.set("n", "<leader>lr", function()
    tl_builtin.lsp_references(generic_layout)
end, { desc = "Telescope LSP References" })

vim.keymap.set("n", "<leader>lic", function()
    tl_builtin.lsp_incoming_calls(generic_layout)
end, { desc = "Telescope LSP Incoming Calls" })

vim.keymap.set("n", "<leader>loc", function()
    tl_builtin.lsp_outgoing_calls(generic_layout)
end, { desc = "Telescope LSP Outgoing Calls" })

vim.keymap.set("n", "<leader>wd", function()
    tl_builtin.diagnostics(vim.tbl_extend("force", generic_layout, { bufnr = 0 }))
end, { desc = "Telescope Workspace Diagnostics" })

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Actions (builtin)" })
vim.keymap.set("n", "<leader>le", function()
    vim.diagnostic.open_float(nil, {
        focus = false,
        scope = "line",
        border = "rounded",
    })
end, { desc = "Show line diagnostics in floating window" })
vim.keymap.set("n", "<leader>lh", function()
    vim.lsp.buf.hover({
        border = "rounded",
        focusable = true,
    })
end, { desc = "Show LSP hover information" })


-- ///////////////////////// source colour scheme//////////////////
vim.cmd.colorscheme('vesper')
