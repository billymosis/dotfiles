-- =============================================================================
-- BASIC SETTINGS
-- =============================================================================
--
local function command_exists(name)
	local commands = vim.api.nvim_get_commands({})
	return commands[name] ~= nil
end

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

vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.hlsearch = true

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
vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "gopls", "html" })

-- LSP completion setup (Replaced by mini.completion)
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(ev)
-- 		local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 		if client and client:supports_method("textDocument/completion") then
-- 			vim.cmd("set completeopt+=menuone,popup,fuzzy")
-- 			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
-- 		end
-- 	end,
-- })
vim.cmd("set completeopt+=noselect,menuone,popup,fuzzy")

-- =============================================================================
-- PLUGIN MANAGEMENT
-- =============================================================================

vim.pack.add({
	-- LSP and Language Support
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/tpope/vim-sleuth" },
	{ src = "https://github.com/microsoft/python-type-stubs" },

	-- Formatting
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- Navigation and Files
	{ src = "https://github.com/alexghergh/nvim-tmux-navigation" },
	{ src = "https://github.com/folke/snacks.nvim" },
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
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },

	-- Notes and Documentation
	{ src = "https://github.com/mickael-menu/zk-nvim" },

	-- Utilities
	{ src = "https://github.com/michaelrommel/nvim-silicon" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/folke/lazydev.nvim" },

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
		lualine_y = { { "lsp_status", ignore_lsp = { "mini.snippets" } }, "bo:filetype" },
		lualine_z = { "location" },
	},
	winbar = {
		lualine_c = { { "filename", color = { fg = "#61afef", bg = "none", gui = "italic,bold" } } },
	},

	inactive_winbar = {
		lualine_c = { { "filename", color = { fg = "gray", bg = "none", gui = "italic,bold" } } },
	},
})

-- Conform (Formatting)
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua", lsp_format = "fallback" },
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

-- HACK: Redeclare when sourcing
if command_exists("Silicon") then
	vim.api.nvim_del_user_command("Silicon")
end

-- Silicon (Code Screenshots)
require("nvim-silicon").setup({
	font = "JetBrainsMono NF=34",
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
local Snacks = require("snacks")
Snacks.setup({
	picker = {
		ui_select = true,
	},
})

-- Mini.nvim plugins
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

require("onedark").setup({ transparent = true })
vim.cmd.colorscheme("onedark")

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

-- Search Keymaps
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "[S]earch [K]eymaps" })

-- Search Files
vim.keymap.set("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "[S]earch [F]iles" })

-- Search by Grep
vim.keymap.set("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "[S]earch by [G]rep" })

-- Search Diagnostics
vim.keymap.set("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics" })

-- Search Resume
vim.keymap.set("n", "<leader>sr", function()
	Snacks.picker.resume()
end, { desc = "[S]earch [R]esume" })

-- Search Recent Files
vim.keymap.set("n", "<leader>s.", function()
	Snacks.picker.recent()
end, { desc = '[S]earch Recent Files ("." for repeat)' })

-- Open Buffer
vim.keymap.set("n", "<leader><leader>", function()
	Snacks.picker.buffers()
end, { desc = "Open Buffer" })

-- Code Action
vim.keymap.set("n", "<leader>ca", function()
	vim.lsp.buf.code_action({ apply = true })
end, { desc = "[C]ode [A]ction" })

local function setup_treesitter()
	local autocmd = vim.api.nvim_create_autocmd
	local ts_parsers = {
		"bash",
		"c",
		"dockerfile",
		"fish",
		"git_config",
		"git_rebase",
		"gitattributes",
		"gitcommit",
		"gitignore",
		"go",
		"gomod",
		"gosum",
		"html",
		"javascript",
		"json",
		"lua",
		"make",
		"markdown",
		"python",
		"rust",
		"sql",
		"toml",
		"tsx",
		"typescript",
		"typescriptreact",
		"typst",
		"vim",
		"yaml",
		"zig",
		"regex",
	}
	local nts = require("nvim-treesitter")
	nts.install(ts_parsers)
	autocmd("PackChanged", { -- update treesitter parsers/queries with plugin updates
		group = augroup,
		callback = function(args)
			local spec = args.data.spec
			if spec and spec.name == "nvim-treesitter" and args.data.kind == "update" then
				vim.schedule(function()
					nts.update()
				end)
			end
		end,
	})
	autocmd("FileType", {
		pattern = ts_parsers,
		callback = function()
			-- syntax highlighting, provided by Neovim
			vim.treesitter.start()
			-- folds, provided by Neovim
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			-- indentation, provided by nvim-treesitter
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})
end
setup_treesitter()

require("blink.cmp").setup({
	signature = { enabled = true },
})

require("lazydev").setup({
	signature = { enabled = true },
})

-- Absolute path
vim.keymap.set("n", "<leader>cF", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
	print("Copied absolute path: " .. vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })

-- Path relative to current working directory
vim.keymap.set("n", "<leader>cr", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
	print("Copied relative path: " .. vim.fn.expand("%"))
end, { desc = "Copy file path relative to CWD" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
