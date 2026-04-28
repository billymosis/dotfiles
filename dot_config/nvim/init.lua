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
vim.o.cmdheight = 1
vim.o.autoread = true

require("vim._core.ui2").enable({
	enable = true,
	msg = {
		targets = "msg",
		msg = {
			height = 0.5,
			timeout = 4000,
		},
	},
})

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
-- SEARCH & CLIPBOARD
-- =============================================================================

vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.hlsearch = true

-- Clear search highlights on Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- =============================================================================
-- PLUGIN DEFINITIONS & CONFIGURATIONS
-- =============================================================================

local plugins = {
	-- -------------------------------------------------------------------------
	-- LSP and Language Support
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/neovim/nvim-lspconfig",
		setup = function()
			vim.lsp.enable({
				"lua_ls",
				"pyright",
				"ts_ls",
				"gopls",
				"html",
				"bash-language-server",
				"kotlin-lsp",
				"copilot",
				"templ",
				"clangd",
			})
			vim.cmd("set completeopt+=noselect,menuone,popup,fuzzy")
			vim.lsp.config("bash-language-server", {})
		end,
	},
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
		setup = function()
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

			local augroup = vim.api.nvim_create_augroup("TreesitterUpdates", { clear = true })
			autocmd("PackChanged", {
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
		end,
	},
	{
		src = "https://github.com/mason-org/mason.nvim",
		setup = function()
			require("mason").setup()
		end,
	},
	{ src = "https://github.com/tpope/vim-sleuth" },
	{ src = "https://github.com/microsoft/python-type-stubs" },
	{
		src = "https://github.com/mfussenegger/nvim-jdtls",
		setup = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = function()
					local jdtls = require("jdtls")
					local mason_path = vim.fn.stdpath("data") .. "/mason"
					local jdtls_path = mason_path .. "/bin/jdtls"
					local lombok_path = mason_path .. "/packages/jdtls/lombok.jar"

					local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
					local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
					local bundles = {}

					local debug_path = vim.fn.stdpath("data")
						.. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
					local debug_bundle = vim.fn.glob(debug_path, 1)
					if type(debug_bundle) == "string" then
						vim.list_extend(bundles, { debug_bundle })
					end

					local test_path = vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar"
					local test_bundle_list = vim.split(vim.fn.glob(test_path, 1), "\n")

					if test_bundle_list[1] ~= "" then
						local excluded =
							{ "com.microsoft.java.test.runner-jar-with-dependencies.jar", "jacocoagent.jar" }
						for _, bundle in ipairs(test_bundle_list) do
							local fname = vim.fn.fnamemodify(bundle, ":t")
							if not vim.tbl_contains(excluded, fname) then
								table.insert(bundles, bundle)
							end
						end
					end

					local config = {
						cmd = { jdtls_path, "--jvm-arg=-javaagent:" .. lombok_path, "-data", workspace_dir },
						root_dir = vim.fs.dirname(vim.fs.find({ ".git", "mvnw", "gradlew" }, { upward = true })[1]),
						init_options = { bundles = bundles },
						on_attach = function(client, bufnr)
							jdtls.setup_dap({ hotcodereplace = "auto" })
							require("jdtls.dap").setup_dap_main_class_configs()
							vim.keymap.set("n", "<leader>df", jdtls.test_class, { buffer = bufnr })
							vim.keymap.set("n", "<leader>dn", jdtls.test_nearest_method, { buffer = bufnr })
						end,
					}
					jdtls.start_or_attach(config)
				end,
			})

			vim.api.nvim_create_user_command("JavaConfig", function()
				require("jdtls.dap").setup_dap_main_class_configs()
				vim.notify("JDTLS: Refreshing debug configurations...", vim.log.levels.INFO)
			end, {})
		end,
	},

	-- -------------------------------------------------------------------------
	-- Formatting
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/stevearc/conform.nvim",
		setup = function()
			local prettierd = { "prettierd", "prettier", stop_after_first = true }
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
					cpp = { "clang-format" },
					sql = { "pg_format" },
				},
			})
			vim.keymap.set("n", "<leader>lf", function()
				require("conform").format({ async = true })
			end, { desc = "Format buffer" })
		end,
	},

	-- -------------------------------------------------------------------------
	-- Navigation and Files
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/alexghergh/nvim-tmux-navigation",
		setup = function()
			require("nvim-tmux-navigation").setup({
				disable_when_zoomed = true,
				keybindings = {
					left = "<C-h>",
					down = "<C-j>",
					up = "<C-k>",
					right = "<C-l>",
				},
			})
		end,
	},
	{
		src = "https://github.com/folke/snacks.nvim",
		setup = function()
			local Snacks = require("snacks")
			Snacks.setup({
				picker = { ui_select = true },
				gitbrowse = {},
				terminal = {},
				input = {},
			})

			-- Search Keymaps
			vim.keymap.set("n", "<leader>sk", Snacks.picker.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sj", Snacks.picker.jumps, { desc = "[S]earch [J]umps" })
			vim.keymap.set("n", "<leader>sf", Snacks.picker.files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>sg", Snacks.picker.grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", Snacks.picker.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", Snacks.picker.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", Snacks.picker.recent, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", Snacks.picker.buffers, { desc = "Open Buffer" })

			-- LSP Navigation
			local map = function(keys, func, desc)
				vim.keymap.set("n", keys, func, { desc = "LSP: " .. desc })
			end
			map("gd", Snacks.picker.lsp_definitions, "[G]oto [D]efinition")
			map("gr", Snacks.picker.lsp_references, "[G]oto [R]eferences")
			map("gI", Snacks.picker.lsp_implementations, "[G]oto [I]mplementation")
			map("gy", Snacks.picker.lsp_type_definitions, "Goto T[y]pe Definition")
			map("gD", Snacks.picker.lsp_declarations, "[G]oto [D]eclaration")
			vim.keymap.set("n", "<leader>ca", function()
				vim.lsp.buf.code_action({ apply = true })
			end, { desc = "[C]ode [A]ction" })
		end,
	},
	{ src = "https://github.com/airblade/vim-rooter" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{
		src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
		setup = function()
			require("neo-tree").setup({
				filesystem = {
					follow_current_file = { enabled = true, leave_dirs_open = true },
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
								vim.fn.jobstart({ "xdg-open", "-g", path }, { detach = true })
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
				},
			})
			vim.keymap.set("n", "<leader>e", ":Neotree toggle float reveal<CR>", { desc = "NeoTree toggle" })
			vim.keymap.set("n", "<leader>lq", ":Neotree float git_status<CR>", { desc = "NeoTree git" })
		end,
	},

	-- -------------------------------------------------------------------------
	-- Git Integration
	-- -------------------------------------------------------------------------
	{ src = "https://github.com/tpope/vim-fugitive" },
	{
		src = "https://github.com/lewis6991/gitsigns.nvim",
		setup = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

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
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
					map("n", "<leader>tw", gitsigns.toggle_word_diff)
					map({ "o", "x" }, "ih", gitsigns.select_hunk)
				end,
			})
		end,
	},

	-- -------------------------------------------------------------------------
	-- Code Enhancement
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/echasnovski/mini.pairs",
		setup = function()
			require("mini.pairs").setup()
		end,
	},
	{
		src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
		setup = function()
			require("ts_context_commentstring").setup({ enable_autocmd = false })
			local get_option = vim.filetype.get_option
			vim.filetype.get_option = function(filetype, option)
				return option == "commentstring"
						and require("ts_context_commentstring.internal").calculate_commentstring()
					or get_option(filetype, option)
			end
		end,
	},
	{
		src = "https://github.com/echasnovski/mini.comment",
		setup = function()
			require("mini.comment").setup({
				options = {
					custom_commentstring = function()
						return require("ts_context_commentstring.internal").calculate_commentstring()
							or vim.bo.commentstring
					end,
				},
			})
		end,
	},
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1"),
		setup = function()
			require("blink.cmp").setup({
				signature = { enabled = true },
				completion = {
					menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
					documentation = { auto_show = true },
				},
			})
		end,
	},
	{
		src = "https://github.com/tronikelis/ts-autotag.nvim",
		setup = function()
			require("ts-autotag").setup({ auto_rename = { enabled = true } })
		end,
	},

	-- -------------------------------------------------------------------------
	-- Utilities
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/nvim-lualine/lualine.nvim",
		setup = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					component_separators = "|",
					section_separators = "",
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 3 } },
					lualine_x = {},
					lualine_y = { { "lsp_status" }, "bo:filetype" },
					lualine_z = { "location" },
				},
				winbar = {
					lualine_c = { { "filename", color = { fg = "#61afef", bg = "none", gui = "italic,bold" } } },
				},
				inactive_winbar = {
					lualine_c = { { "filename", color = { fg = "gray", bg = "none", gui = "italic,bold" } } },
				},
			})
		end,
	},
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{
		src = "https://github.com/folke/lazydev.nvim",
		setup = function()
			require("lazydev").setup({ signature = { enabled = true } })
		end,
	},
	{
		src = "https://github.com/kwkarlwang/bufjump.nvim",
		setup = function()
			local bufjump = require("bufjump")
			vim.keymap.set("n", "[w", bufjump.backward, { desc = "Jump to previous file in jumplist" })
			vim.keymap.set("n", "]w", bufjump.forward, { desc = "Jump to next file in jumplist" })
		end,
	},
	{ src = "https://github.com/esmuellert/codediff.nvim" },
	{
		src = "https://github.com/OXY2DEV/markview.nvim",
		setup = function()
			require("markview").setup({
				preview = {
					filetypes = { "markdown" },
					ignore_buftypes = { "nofile" },
				},
			})
		end,
	},

	-- -------------------------------------------------------------------------
	-- Theme
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/rebelot/kanagawa.nvim",
		setup = function()
			require("kanagawa").setup({
				transparent = true,
				colors = {
					theme = {
						all = { ui = { bg_gutter = "none", pmenu = { bg = "none" } } },
					},
				},
				overrides = function(colors)
					local theme = colors.theme
					return {
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },
						NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
						LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						Pmenu = { fg = theme.ui.shade0, bg = "none" },
						PmenuSbar = { bg = "none" },
						PmenuThumb = { bg = "none" },
					}
				end,
			})
			vim.cmd.colorscheme("kanagawa")
		end,
	},

	-- -------------------------------------------------------------------------
	-- AI Tools
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/zbirenbaum/copilot.lua",
		setup = function()
			vim.api.nvim_set_hl(0, "CopilotSuggestion", { italic = true, fg = "#555555" })
			vim.api.nvim_create_autocmd("InsertEnter", {
				once = true,
				callback = function()
					vim.cmd.packadd("copilot.lua")
					require("copilot").setup({
						suggestion = { auto_trigger = true },
						server_opts_overrides = { settings = { telemetry = { telemetryLevel = "off" } } },
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
		end,
	},
	{ src = "https://github.com/copilotlsp-nvim/copilot-lsp" },
	{ src = "https://github.com/coder/claudecode.nvim" },
	{ src = "https://github.com/folke/sidekick.nvim" },
	{ src = "https://github.com/NickvanDyke/opencode.nvim" },

	-- -------------------------------------------------------------------------
	-- Debugger
	-- -------------------------------------------------------------------------
	{
		src = "https://github.com/mfussenegger/nvim-dap",
		setup = function()
			require("dapui").setup()
			require("nvim-dap-virtual-text").setup({})
			require("dap.ext.vscode").getconfigs()

			-- Debugger Keymaps
			vim.keymap.set("n", "<F5>", ":DapContinue<CR>", { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F10>", ":DapStepOver<CR>", { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F11>", ":DapStepInto<CR>", { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F12>", ":DapStepOut<CR>", { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>b", ":DapToggleBreakpoint<CR>", { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Set Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>du", function()
				require("dapui").toggle()
			end, { desc = "Debug: Toggle UI" })
		end,
	},
	{ src = "https://github.com/jay-babu/mason-nvim-dap.nvim" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
}

-- =============================================================================
-- PLUGIN INITIALIZATION
-- =============================================================================

vim.pack.add(vim.tbl_map(function(p)
	return {
		src = p.src,
		version = p.version,
		name = p.name,
	}
end, plugins))

for _, p in ipairs(plugins) do
	_ = p.setup and p.setup()
end

require("user.utils")
require("user.ai")

-- =============================================================================
-- GENERAL KEYMAPS & AUTOCOMMANDS
-- =============================================================================

vim.keymap.set("n", "<Leader>cr", function()
	vim.cmd("%s/\\r$//g")
	print("CRLF line endings converted to LF")
end, { desc = "Convert CRLF to LF in whole buffer" })

-- Undo Tree (Packadd approach)
vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>u", require("undotree").open)

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Terminal Setup (Opencode & Tmux binds)
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

		if string.find(name, "opencode") then
			tnoremap("<C-d>", function()
				require("opencode").command("session.half.page.down")
			end, { buffer = buffer })
			tnoremap("<C-u>", function()
				require("opencode").command("session.half.page.up")
			end, { buffer = buffer })
		end

		tnoremap("jk", "<C-\\><C-n>", { buffer = buffer })
		tnoremap("<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { buffer = buffer })
		tnoremap("<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { buffer = buffer })
		tnoremap("<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { buffer = buffer })
		tnoremap("<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { buffer = buffer })
	end,
})

-- Auto-sync notes to pCloud
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = os.getenv("HOME") .. "/my-notes/**/*.md",
	callback = function()
		local cloud = os.getenv("ZK_CLOUD_DIR")
		local local_p = os.getenv("ZK_NOTEBOOK_DIR")
		if cloud and local_p then
			vim.fn.jobstart({
				"rsync",
				"-rtu",
				"--exclude=.git/",
				"--exclude=.trash/",
				"--exclude=book/",
				"--exclude=*.pdf",
				"--exclude=*.epub",
				local_p .. "/",
				cloud .. "/",
			})
		end
	end,
})

-- Context Menu (<leader>q)
local function feed_cmd(cmd)
	local keys = vim.api.nvim_replace_termcodes(":" .. cmd .. " ", true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end

vim.keymap.set({ "n", "v" }, "<leader>q", function()
	local opts = {
		{
			name = "Context: Query Location",
			action = function()
				feed_cmd("Ql")
			end,
		},
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
		{
			name = "Context: Query Snippet",
			action = function()
				feed_cmd("Qs")
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

-- Settings Menu (<leader>w)
vim.keymap.set({ "n", "v" }, "<leader>w", function()
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
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end,
		},
		{
			name = "Git: View file history",
			action = function()
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
