-- =============================================================================
-- BASIC SETTINGS
-- =============================================================================

-- UI Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.cursorline = true
vim.o.winborder = "rounded"

-- Indentation
vim.o.tabstop = 4

-- Files and Backup
vim.o.swapfile = false
vim.opt.undofile = true

-- Visual Characters
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Command Preview
vim.opt.inccommand = "split"

-- Leader Key
vim.g.mapleader = " "

-- =============================================================================
-- SEARCH SETTINGS
-- =============================================================================

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Clear search highlights on Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- =============================================================================
-- CLIPBOARD
-- =============================================================================

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- =============================================================================
-- LSP CONFIGURATION
-- =============================================================================

-- Enable built-in LSP for common languages
vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "gopls" })

-- LSP completion setup
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.cmd("set completeopt+=menuone,popup,fuzzy")
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})
vim.cmd("set completeopt=noselect")

-- =============================================================================
-- PLUGIN MANAGEMENT
-- =============================================================================

vim.pack.add({
	-- LSP and Language Support
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/tpope/vim-sleuth" },
	{ src = "https://github.com/microsoft/python-type-stubs" },

	-- Formatting
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- Navigation and Files
	{ src = "https://github.com/alexghergh/nvim-tmux-navigation" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/echasnovski/mini.extra" },
	{ src = "https://github.com/echasnovski/mini.files" },
	{ src = "https://github.com/airblade/vim-rooter" },

	-- Git Integration
	{ src = "https://github.com/sindrets/diffview.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/tpope/vim-fugitive" },

	-- Code Enhancement
	{ src = "https://github.com/echasnovski/mini.pairs" },
	{ src = "https://github.com/echasnovski/mini.comment" },
	{ src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },

	-- Language Specific
	{ src = "https://github.com/ray-x/go.nvim" },
	{ src = "https://github.com/ray-x/guihua.lua" },

	-- Notes and Documentation
	{ src = "https://github.com/mickael-menu/zk-nvim" },

	-- Utilities
	{ src = "https://github.com/michaelrommel/nvim-silicon" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },

	-- Theme
	{ src = "https://github.com/navarasu/onedark.nvim" },
})

-- =============================================================================
-- PLUGIN CONFIGURATIONS
-- =============================================================================

-- Lualine (Status Line)
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "onedark",
		component_separators = "|",
		section_separators = "",
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 3 } },
		lualine_x = {},
		lualine_y = { "lsp_status", "bo:filetype" },
		lualine_z = { "location" },
	},
	winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { "filename", color = { fg = "#61afef", bg = "none", gui = "italic,bold" } } },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},

	inactive_winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { "filename", color = { fg = "gray", bg = "none", gui = "italic,bold" } } },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
})

-- Conform (Formatting)
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofmt" },
		python = function(bufnr)
			if require("conform").get_formatter_info("ruff_format", bufnr).available then
				return { "ruff_format" }
			else
				return { "isort", "black" }
			end
		end,
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		less = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		["markdown.mdx"] = { "prettier" },
		md = { "prettier" },
		graphql = { "prettier" },
		handlebars = { "prettier" },
	},
})

-- Treesitter
require("nvim-treesitter.configs").setup({
	auto_install = true,
	highlight = {
		enable = true,
	},
})

-- Go.nvim with auto-formatting
local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		require("go.format").goimports()
	end,
	group = format_sync_grp,
})
require("go").setup()

-- Gitsigns
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end)

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end)

		-- Actions
		map("n", "<leader>hs", gitsigns.stage_hunk)
		map("n", "<leader>hr", gitsigns.reset_hunk)
		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end)
		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end)
		map("n", "<leader>hS", gitsigns.stage_buffer)
		map("n", "<leader>hR", gitsigns.reset_buffer)
		map("n", "<leader>hp", gitsigns.preview_hunk)
		map("n", "<leader>hi", gitsigns.preview_hunk_inline)
		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end)
		map("n", "<leader>hd", gitsigns.diffthis)
		map("n", "<leader>hD", function()
			gitsigns.diffthis("~")
		end)
		map("n", "<leader>hQ", function()
			gitsigns.setqflist("all")
		end)
		map("n", "<leader>hq", gitsigns.setqflist)

		-- Toggles
		map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
		map("n", "<leader>tw", gitsigns.toggle_word_diff)

		-- Text object
		map({ "o", "x" }, "ih", gitsigns.select_hunk)
	end,
})

-- ZK (Zettelkasten)
require("zk").setup({
	picker = "select",
	lsp = {
		config = {
			name = "zk",
			cmd = { "zk", "lsp" },
			filetypes = { "markdown" },
			on_attach = function(client, bufnr) end,
		},
		auto_attach = {
			enabled = true,
		},
	},
})

-- Silicon (Code Screenshots)
require("silicon").setup({
	font = "JetBrainsMono NF=34;Noto Color Emoji=34",
	output = function()
		return "~/Pictures/Codes/" .. os.date("!%Y-%m-%dT%H-%M-%S") .. ".png"
	end,
	to_clipboard = true,
	pad_horiz = 0,
	pad_vert = 0,
	line_offset = function(args)
		return args.line1
	end,
	tab_width = 2,
	window_title = function()
		local full_path = vim.fn.expand("%:p")
		local relative_path = vim.fn.fnamemodify(full_path, ":~:.")
		return "Bimo | " .. relative_path
	end,
})

-- Mini.nvim plugins
require("mini.pick").setup()
require("mini.extra").setup()
require("mini.files").setup()
require("mini.pairs").setup()

-- Comment setup with context awareness
require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
	return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
		or get_option(filetype, option)
end

require("mini.comment").setup({
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})

-- Mason (LSP installer)
require("mason").setup()

-- TMUX Navigation
require("nvim-tmux-navigation").setup({
	disable_when_zoomed = true,
	keybindings = {
		left = "<C-h>",
		down = "<C-j>",
		up = "<C-k>",
		right = "<C-l>",
	},
})

-- =============================================================================
-- THEME AND APPEARANCE
-- =============================================================================

require("onedark").setup()
vim.cmd.colorscheme("onedark")

-- Transparent background
vim.cmd([[
	highlight Normal guibg=none
	highlight NonText guibg=none
	highlight Normal ctermbg=none
	highlight NonText ctermbg=none
	highlight EndOfBuffer guibg=NONE ctermbg=NONE
	highlight clear SignColumn
]])

-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- File Management
local MiniFiles = require("mini.files")
local minifiles_toggle = function()
	if not MiniFiles.close() then
		MiniFiles.open(vim.api.nvim_buf_get_name(0))
	end
end
vim.keymap.set("n", "<leader>e", minifiles_toggle, { desc = "Toggle mini files" })

-- Formatting
vim.keymap.set("n", "<leader>lf", function()
	require("conform").format({ async = true })
end, { desc = "Format buffer" })

-- Search and Navigation
vim.keymap.set("n", "<leader>sh", ":Pick help<CR>", { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", ":Pick keymaps<CR>", { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", ":Pick files<CR>", { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", ":Pick grep_live<CR>", { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", ":Pick diagnostic<CR>", { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", ":Pick resume<CR>", { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", ":Pick oldfiles<CR>", { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", ":Pick buffers<CR>", { desc = "Open Buffer" })
