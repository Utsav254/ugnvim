-- Basic Personal Settings
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.number = true
vim.o.relativenumber = true

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
        "rebelot/kanagawa.nvim",
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
                -- LSP stuff
                "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
                -- Lua Line
                {
                        "nvim-lualine/lualine.nvim",
                        dependencies = { "nvim-tree/nvim-web-devicons" }
                }
    },
    install = { colorscheme = { "kanagawa" } },
    checker = { enabled = true },
    rocks = { enabled = false },
})

-- Kanagawa Colour Scheme options
require('kanagawa').setup({
    compile = true,
        commentStyle = { italic = false },
    keywordStyle = { italic = false },
    statementStyle = { bold = false },
})

-- Indent blank lines options
require("ibl").setup({
        indent = {char = "│"},
        scope = { enabled = true },
})

-- Auto Pairs options
require('nvim-autopairs').setup()

-- Comments options
require('Comment').setup()

-- Neotree options
require('neo-tree').setup()
vim.api.nvim_set_keymap("n", "<leader>ee", ":Neotree toggle<CR>", { noremap = true, silent = true })

-- Telescope options
require("telescope").setup({
        pickers =
        {
                find_files = { theme = "dropdown" },
                live_grep = { theme = "dropdown" },
                current_buffer_fuzzy_find = { theme = "dropdown" },
        },
})

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg",
        function()
                builtin.live_grep({ cwd = vim.fn.getcwd() })
        end)

vim.keymap.set("n", "<leader>fs", builtin.current_buffer_fuzzy_find)

-- LSP configurations
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "zls"},
})
local lspconfig = require("lspconfig")

lspconfig.clangd.setup({})
lspconfig.zls.setup({})

-- LSP Keybindings
vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

vim.keymap.set("n", "<leader>ld", function()
    local params = vim.lsp.util.make_position_params()
    vim.api.nvim_command("normal! m'")  -- Mark current position before jumping

    vim.lsp.buf_request(0, "textDocument/declaration", params, function(err, result)
        if not result or vim.tbl_isempty(result) then
            vim.lsp.buf.definition()  -- If no declaration, go to definition
        else
            vim.lsp.buf.declaration()  -- Otherwise, go to declaration
        end
    end)
end, { desc = "Toggle between declaration and definition (with return support)" })


vim.keymap.set("n", "<leader>le",
        function()
                vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
        end)

-- Lua Line options
require('lualine').setup()


vim.cmd("colorscheme kanagawa-dragon")
