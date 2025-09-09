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
vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "gopls", "html", "jdtls", "java" })
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
	{ src = "https://github.com/ray-x/go.nvim" },

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

	-- Notes and Documentation
	{ src = "https://github.com/mickael-menu/zk-nvim" },

	-- Utilities
	{ src = "https://github.com/michaelrommel/nvim-silicon" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/folke/lazydev.nvim" },

	-- Theme
	{ src = "https://github.com/navarasu/onedark.nvim" },

	-- AI
	-- { src = "https://github.com/github/copilot.vim" },
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/olimorris/codecompanion.nvim" },
	{ src = "https://github.com/ravitemer/codecompanion-history.nvim" },
	{ src = "https://github.com/OXY2DEV/markview.nvim" },
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
		lualine_y = {
			{ "lsp_status", ignore_lsp = { "mini.snippets", "Copilot", "GitHub Copilot", "copilot" } },
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

	local highlight_filetypes = vim.deepcopy(ts_parsers)
	table.insert(highlight_filetypes, "codecompanion")

	autocmd("FileType", {
		pattern = highlight_filetypes,
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

-- Code companion
require("codecompanion").setup({
	opts = {
		log_level = "DEBUG", -- or "TRACE"
	},
	extensions = {
		history = {
			enabled = true,
			opts = {
				-- Keymap to open history from chat buffer (default: gh)
				keymap = "gh",
				-- Keymap to save the current chat manually (when auto_save is disabled)
				save_chat_keymap = "sc",
				-- Save all chats by default (disable to save only manually using 'sc')
				auto_save = true,
				-- Number of days after which chats are automatically deleted (0 to disable)
				expiration_days = 0,
				-- Picker interface (auto resolved to a valid picker)
				picker = "snacks", --- ("telescope", "snacks", "fzf-lua", or "default")
				---Optional filter function to control which chats are shown when browsing
				chat_filter = nil, -- function(chat_data) return boolean end
				-- Customize picker keymaps (optional)
				picker_keymaps = {
					rename = { n = "r", i = "<M-r>" },
					delete = { n = "d", i = "<M-d>" },
					duplicate = { n = "<C-y>", i = "<C-y>" },
				},
				---Automatically generate titles for new chats
				auto_generate_title = true,
				title_generation_opts = {
					---Adapter for generating titles (defaults to current chat adapter)
					adapter = "copilot", -- "copilot"
					---Model for generating titles (defaults to current chat model)
					model = "gpt-4o", -- "gpt-4o"
					---Number of user prompts after which to refresh the title (0 to disable)
					refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
					---Maximum number of times to refresh the title (default: 3)
					max_refreshes = 3,
					format_title = function(original_title)
						-- this can be a custom function that applies some custom
						-- formatting to the title.
						return original_title
					end,
				},
				---On exiting and entering neovim, loads the last chat on opening chat
				continue_last_chat = false,
				---When chat is cleared with `gx` delete the chat from history
				delete_on_clearing_chat = false,
				---Directory path to save the chats
				dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
				---Enable detailed logging for history extension
				enable_logging = false,

				-- Summary system
				summary = {
					-- Keymap to generate summary for current chat (default: "gcs")
					create_summary_keymap = "gcs",
					-- Keymap to browse summaries (default: "gbs")
					browse_summaries_keymap = "gbs",

					generation_opts = {
						adapter = "copilot", -- defaults to current chat adapter
						model = "gpt-4o", -- defaults to current chat model
						context_size = 90000, -- max tokens that the model supports
						include_references = true, -- include slash command content
						include_tool_outputs = true, -- include tool execution results
						system_prompt = nil, -- custom system prompt (string or function)
						format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
					},
				},
			},
		},
	},
})

-- vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
require("markview").setup({
	preview = {
		filetypes = { "markdown", "codecompanion" },
		ignore_buftypes = {},
	},
})

vim.api.nvim_set_hl(0, "CopilotSuggestion", { italic = true, fg = "#555555" })
require("copilot").setup({
	server_opts_overrides = {
		settings = {
			telemetry = {
				telemetryLevel = "off",
			},
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>w", function()
	local mode = vim.fn.mode()
	local opts = {
		{
			name = "Code Companion Action",
			action = function()
				if mode == "v" or mode == "V" or mode == "\22" then -- visual, linewise, blockwise
					-- Run command on selected lines
					vim.cmd(string.format(":'<,'>CodeCompanionActions"))
					-- Optionally, exit visual mode
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
				else
					vim.cmd("CodeCompanionActions")
				end
			end,
		},
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
