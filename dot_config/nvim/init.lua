-- =============================================================================
-- BASIC SETTINGS
-- =============================================================================
--
local function command_exists(name)
	local commands = vim.api.nvim_get_commands({})
	return commands[name] ~= nil
end

require("user.utils")

-- if vim.fn.has("wsl") then
-- 	vim.g.clipboard = {
-- 		name = "win32yank-wsl",
-- 		copy = {
-- 			["+"] = "win32yank.exe -i --crlf",
-- 			["*"] = "win32yank.exe -i --crlf",
-- 		},
-- 		paste = {
-- 			["+"] = "win32yank.exe -o --lf",
-- 			["*"] = "win32yank.exe -o --lf",
-- 		},
-- 		cache_enabled = true,
-- 	}
-- end

-- UI Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.cursorline = true
vim.o.winborder = "rounded"
vim.o.cmdheight = 1

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
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"ts_ls",
	"gopls",
	"html",
	"jdtls",
	"java",
	"bash-language-server",
	"kotlin-lsp",
	"copilot",
	"templ",
})
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
	{ src = "https://github.com/mfussenegger/nvim-jdtls" },

	-- Formatting
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- Navigation and Files
	{ src = "https://github.com/alexghergh/nvim-tmux-navigation" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/airblade/vim-rooter" },
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },

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

	-- Utilities
	{ src = "https://github.com/michaelrommel/nvim-silicon" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/folke/lazydev.nvim" },
	{ src = "https://github.com/kwkarlwang/bufjump.nvim" },
	{ src = "https://github.com/tronikelis/ts-autotag.nvim" },
	{ src = "https://github.com/tpope/vim-dadbod" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	{ src = "https://github.com/esmuellert/vscode-diff.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },

	-- Theme
	{ src = "https://github.com/navarasu/onedark.nvim" },
	{ src = "https://github.com/darianmorat/gruvdark.nvim" },
	{ src = "https://github.com/rebelot/kanagawa.nvim" },

	-- AI
	-- { src = "https://github.com/github/copilot.vim" },
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/copilotlsp-nvim/copilot-lsp" },
	{ src = "https://github.com/coder/claudecode.nvim" },

	{ src = "https://github.com/OXY2DEV/markview.nvim" },
	{ src = "https://github.com/folke/sidekick.nvim" },
})

-- =============================================================================
-- PLUGIN CONFIGURATIONS
-- =============================================================================

require("claudecode").setup({
	terminal = {
		split_width_percentage = 0.5,
	},
})

vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
vim.keymap.set("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

vim.api.nvim_create_autocmd("FileType", {
	desc = "Add file",
	group = vim.api.nvim_create_augroup("ClaudeCodeFileAdd", { clear = true }),
	pattern = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
	callback = function()
		vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { desc = "Add file" })
	end,
})

local tnoremap = function(lhs, rhs, opts)
	opts = opts or {}
	opts.silent = true
	vim.keymap.set("t", lhs, rhs, opts)
end

vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		local buffer = vim.api.nvim_get_current_buf()
		local name = vim.api.nvim_buf_get_name(buffer)
		vim.print(name)

		if string.find(name, "claude") then
			-- 	-- Switch to normal mode when pressing Escape in terminal mode
			tnoremap("<Esc>", "<C-\\><C-n>", { buffer = buffer })
			--
			-- Send Escape when pressing Ctrl-X in terminal mode
			tnoremap("<C-x>", "<Esc>", { buffer = buffer })

			-- Map Ctrl+h/j/k/l to navigate between tmux panes
			tnoremap("<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { buffer = buffer })
			tnoremap("<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { buffer = buffer })
			tnoremap("<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { buffer = buffer })
			tnoremap("<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { buffer = buffer })
		end
	end,
})

-- Sidekick
require("sidekick").setup({
	nes = {
		enabled = false,
	},
	cli = {
		enabled = true,
		mux = {
			enabled = true,
			backend = "tmux",
		},
		tools = {
			deepseek = { cmd = { "claude", "--settings", os.getenv("HOME") .. "/.claude/env.json" } },
		},
	},
})

vim.keymap.set("n", "<leader>n", function()
	require("sidekick").nes_jump_or_apply()
end, { desc = "Goto/Apply Next Edit Suggestion" })

vim.keymap.set("", "<leader>df", function()
	require("sidekick.cli").send({ msg = "{file}" })
end, { desc = "Send File" })

vim.keymap.set("x", "<leader>ds", function()
	require("sidekick.cli").send({ msg = "{selection}" })
end, { desc = "Send Visual Selection" })

vim.keymap.set({ "x", "n" }, "<leader>dt", function()
	require("sidekick.cli").send({ msg = "{this}" })
end, { desc = "Send This" })

vim.keymap.set("", "<leader>dc", function()
	require("sidekick.cli").toggle({ name = "copilot", focus = false })
end, { desc = "Sidekick toggle copilot" })

-- Autotag
require("ts-autotag").setup({
	auto_rename = {
		enabled = true,
	},
})

-- Lualine (Status Line)
require("lualine").setup({
	options = {
		icons_enabled = true,
		-- theme = "onedark",
		component_separators = "|",
		section_separators = "",
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 3 } },
		lualine_x = {},
		lualine_y = {
			{ "lsp_status" },
			"bo:filetype",
		},
		lualine_z = { "location" },
	},
	winbar = {
		lualine_c = { { "filename", color = { fg = "#61afef", bg = "none", gui = "italic,bold" } } },
	},

	inactive_winbar = {
		lualine_c = { { "filename", color = { fg = "gray", bg = "none", gui = "italic,bold" } } },
	},
})
local prettierd = { "prettierd", "prettier", stop_after_first = true }

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
		javascript = prettierd,
		java = { "google-java-format" },
		javascriptreact = prettierd,
		typescript = prettierd,
		typescriptreact = prettierd,
		vue = prettierd,
		css = prettierd,
		scss = prettierd,
		less = prettierd,
		html = prettierd,
		json = prettierd,
		jsonc = prettierd,
		yaml = prettierd,
		markdown = prettierd,
		["markdown.mdx"] = prettierd,
		md = prettierd,
		graphql = prettierd,
		handlebars = prettierd,
		templ = { "templ" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
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
	gitbrowse = {},
})

-- Mini.nvim plugins
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
local mason_path = vim.fn.stdpath("data")

vim.lsp.config("jdtls", {
	cmd = {
		vim.fn.expand(mason_path .. "/mason/bin/jdtls"),
		("--jvm-arg=-javaagent:%s"):format(vim.fn.expand(mason_path .. "/mason/packages/jdtls/lombok.jar")),
	},
})
vim.lsp.config("bash-language-server", {})

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
require("kanagawa").setup({
	transparent = true,
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none",
					pmenu = {
						bg = "none",
					},
				},
			},
		},
	},
	overrides = function(colors)
		local theme = colors.theme
		return {
			NormalFloat = { bg = "none" },
			FloatBorder = { bg = "none" },
			FloatTitle = { bg = "none" },

			-- Save an hlgroup with dark background and dimmed foreground
			-- so that you can use it where your still want darker windows.
			-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
			NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

			-- Popular plugins that open floats will link to NormalFloat by default;
			-- set their background accordingly if you wish to keep them dark and borderless
			LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
			MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
			Pmenu = { fg = theme.ui.shade0, bg = "none" }, -- add `blend = vim.o.pumblend` to enable transparency
			PmenuSbar = { bg = "none" },
			PmenuThumb = { bg = "none" },
		}
	end,
})

vim.cmd.colorscheme("kanagawa")

-- require("onedark").setup({ transparent = true })
-- vim.cmd.colorscheme("onedark")
--
-- require("gruvdark").setup({ transparent = true })
-- vim.cmd.colorscheme("gruvdark")

-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- Formatting
vim.keymap.set("n", "<leader>lf", function()
	require("conform").format({ async = true })
end, { desc = "Format buffer" })

-- Search Keymaps
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "[S]earch [K]eymaps" })

-- Jumps
vim.keymap.set("n", "<leader>sj", function()
	Snacks.picker.jumps()
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
		"markdown_inline",
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
		"kotlin",
		"templ",
	}
	local nts = require("nvim-treesitter")
	nts.install(ts_parsers)
	local augroup = vim.api.nvim_create_augroup("TreesitterUpdates", { clear = true }) -- define augroup
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
			vim.treesitter.start()
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})
end
setup_treesitter()

require("blink.cmp").setup({
	signature = { enabled = true },
	completion = {
		menu = {
			draw = {
				columns = { { "label", "label_description", gap = 1 }, { "kind" } },
			},
		},
		documentation = {
			auto_show = true,
		},
	},
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

vim.keymap.set("n", "<Leader>cr", function()
	vim.cmd("%s/\\r$//g")
	print("CRLF line endings converted to LF")
end, { desc = "Convert CRLF to LF in whole buffer" })

require("neo-tree").setup({
	filesystem = {
		follow_current_file = {
			enabled = true,
			leave_dirs_open = true,
		},
		window = {
			mappings = {
				["<leader>e"] = "close_window",
				["h"] = function(state)
					local node = state.tree:get_node()
					if node.type == "directory" and node:is_expanded() then
						require("neo-tree.sources.filesystem").toggle_directory(state, node)
					else
						require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
					end
				end,
				["O"] = function(state)
					local node = state.tree:get_node()
					local path = node:get_id()
					-- macOs: open file in default application in the background.
					vim.fn.jobstart({ "xdg-open", "-g", path }, { detach = true })
					-- Linux: open file in default application
					vim.fn.jobstart({ "xdg-open", path }, { detach = true })
				end,
				["l"] = function(state)
					local node = state.tree:get_node()
					if node.type == "directory" then
						if not node:is_expanded() then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						elseif node:has_children() then
							require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
						end
					end
				end,
			},
		},
	}, -- options go here
})

-- File Management
vim.keymap.set("n", "<leader>e", ":Neotree toggle float reveal<CR>", { desc = "NeoTree toggle" })
vim.keymap.set("n", "<leader>lq", ":Neotree float git_status<CR>", { desc = "NeoTree git" })

local map = function(keys, func, desc)
	vim.keymap.set("n", keys, func, { desc = "LSP: " .. desc })
end

-- Code Action
vim.keymap.set("n", "<leader>ca", function()
	vim.lsp.buf.code_action({ apply = true })
end, { desc = "[C]ode [A]ction" })

map("gd", function()
	require("snacks").picker.lsp_definitions()
end, "[G]oto [D]efinition")
-- Find references for the word under your cursor.
map("gr", function()
	require("snacks").picker.lsp_references()
end, "[G]oto [R]eferences")

-- Jump to the implementation of the word under your cursor.
-- Useful when your language has ways of declaring types without an actual implementation.
map("gI", function()
	require("snacks").picker.lsp_implementations()
end, "[G]oto [I]mplementation")

-- Jump to the type of the word under your cursor.
-- Useful when you're not sure what type a variable is and you want to see
-- the definition of its *type*, not where it was *defined*.
map("gy", function()
	require("snacks").picker.lsp_type_definitions()
end, "Goto T[y]pe Definition")

map("gD", function()
	require("snacks").picker.lsp_declarations()
end, "[G]oto [D]eclaration")

require("markview").setup({
	preview = {
		filetypes = { "markdown" },
		ignore_buftypes = {},
	},
})

vim.api.nvim_set_hl(0, "CopilotSuggestion", { italic = true, fg = "#555555" })
vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function()
		vim.cmd.packadd("copilot.lua")
		require("copilot").setup({
			suggestion = {
				auto_trigger = true,
			},
			server_opts_overrides = {
				settings = {
					telemetry = { telemetryLevel = "off" },
				},
			},
			nes = {
				enabled = false,
				keymap = {
					accept_and_goto = "<leader>p",
					accept = false,
					dismiss = "<Esc>",
				},
			},
		})
	end,
})

local function feed_cmd(cmd)
	local keys = vim.api.nvim_replace_termcodes(":" .. cmd .. " ", true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end

vim.keymap.set({ "n", "v" }, "<leader>q", function()
	local opts = {
		{
			name = "Context: Grep 'AND' (Find in files with A + B)",
			action = function()
				feed_cmd("Qga")
			end,
		},
		{
			name = "Context: Poupulate Quickfix List",
			action = function()
				feed_cmd("Qc")
			end,
		},
		{
			name = "Context: Poupulate Quickfix List with hunks",
			action = function()
				feed_cmd("Qch")
			end,
		},
		{
			name = "Context: Tree to Buffer (Project Structure)",
			action = function()
				feed_cmd("Qt")
			end,
		},
	}
	vim.ui.select(opts, {
		prompt = "Settings and Options",
		format_item = function(item)
			return item.name
		end,
	}, function(item)
		if item then
			item.action()
		else
			print("No option selected")
		end
	end)
end, { desc = "Context Command" })

vim.keymap.set({ "n", "v" }, "<leader>w", function()
	local mode = vim.fn.mode()
	local opts = {
		{
			name = "Toggle copilot auto trigger",
			action = function()
				require("copilot.suggestion").toggle_auto_trigger()
			end,
		},
		{
			name = "Copilot panel",
			action = function()
				vim.cmd("Copilot panel")
			end,
		},
		{
			name = "Sidekick toggle",
			action = function()
				vim.cmd("Sidekick cli toggle")
			end,
		},
		{
			name = "Grep And",
			action = function()
				vim.cmd("Sidekick cli toggle")
			end,
		},
		{
			name = "Toggle Relative Number",
			action = function()
				vim.o.relativenumber = not vim.o.relativenumber
			end,
		},
		{
			name = "Toggle Wrap",
			action = function()
				vim.o.wrap = not vim.o.wrap
			end,
		},
		{
			name = "Diff current file",
			action = function()
				vim.cmd("Git diff -- %")
			end,
		},
		{
			name = "Toggle Spellcheck",
			action = function()
				vim.o.spell = not vim.o.spell
			end,
		},
		{
			name = "Toggle Inlay Hints",
			action = function()
				-- Toggles LSP inlay hints for the current buffer
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end,
		},
		{
			name = "Git: View file history",
			action = function()
				-- Open the commit history for the current file in a new vertical split
				vim.cmd("Gclog! -- %")
			end,
		},
	}
	vim.ui.select(opts, {
		prompt = "Settings and Options",
		format_item = function(item)
			return item.name
		end,
	}, function(item)
		if item then
			item.action()
		else
			print("No option selected")
		end
	end)
end, { desc = "[S]ettings [O]ptions" })

local bufjump = require("bufjump")
vim.keymap.set("n", "[w", bufjump.backward, { desc = "Jump to previous file in jumplist" })
vim.keymap.set("n", "]w", bufjump.forward, { desc = "Jump to next file in jumplist" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
