require("user.utils")

-- =============================================================================
-- UNIFIED AI CONFIGURATION
-- =============================================================================

-- Helper: Restores selection before running a command
-- This is critical because the Menu UI steals focus/selection
local function run_on_selection(action_fn)
	return function()
		-- 1. Re-select the last visual selection
		vim.cmd("normal! gv")
		-- 2. Run the action (wrapped in schedule to ensure mode switch finishes)
		vim.schedule(function()
			action_fn()
		end)
	end
end

local function ai_action_menu()
	-- 1. Capture current mode
	local mode = vim.fn.mode()
	local is_visual = (mode == "v" or mode == "V" or mode == "\22")

	-- 2. If visual, exit mode immediately to save marks ('< and '>)
	if is_visual then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
	end

	local options = {}

	if is_visual then
		-- VISUAL MODE ACTIONS
		options = {
			{
				name = "Send to Opencode",
				-- We re-select before calling opencode
				action = run_on_selection(function()
					local keys = require("opencode").operator("@this ")
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
				end),
			},
			{
				name = "Send to Claude (Project Ctx)",
				-- Claude commands usually need the range, so we re-select first
				action = run_on_selection(function()
					vim.cmd("ClaudeCodeSend")
				end),
			},
			{
				name = "Send to Sidekick (General Q&A)",
				-- Sidekick reads '{selection}', so we ensure it exists
				action = run_on_selection(function()
					require("sidekick.cli").send({ msg = "{this}" })
				end),
			},
			{
				name = "Sidekick: Explain Code",
				action = run_on_selection(function()
					require("sidekick.cli").send({ msg = "Explain this code:\n\n{selection}" })
				end),
			},
		}
	else
		-- NORMAL MODE ACTIONS (No changes needed here)
		options = {
			{
				name = "Toggle: Opencode Chat",
				action = function()
					require("opencode").toggle()
				end,
			},
			{
				name = "Toggle: Opencode Select",
				action = function()
					require("opencode").select()
				end,
			},
			{
				name = "Toggle: Claude Code",
				action = function()
					vim.cmd("ClaudeCode")
				end,
			},
			{
				name = "Toggle: Sidekick",
				action = function()
					require("sidekick.cli").toggle({ name = "copilot", focus = true })
				end,
			},
		}
	end

	vim.ui.select(options, {
		prompt = is_visual and "AI Actions (Visual)" or "AI Command Center",
		format_item = function(item)
			return item.name
		end,
	}, function(item)
		if item then
			item.action()
		else
			-- If user cancels, and we were in visual mode, be nice and re-select
			if is_visual then
				vim.cmd("normal! gv")
			end
		end
	end)
end

-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- The Only Key You Need To Remember
vim.keymap.set({ "n", "v" }, "<leader>ai", ai_action_menu, { desc = "Unified AI Menu" })

-- Sidekick NES (Next Edit Suggestion) - Keep this distinct as it's a navigation tool
vim.keymap.set("n", "<leader>an", function()
	require("sidekick").nes_jump_or_apply()
end, { desc = "Next Edit Suggestion" })

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

require("claudecode").setup({
	terminal = {
		split_width_percentage = 0.5,
	},
})

-- vim.g.opencode_opts = {
-- 	provider = {
-- 		enabled = "tmux",
-- 		tmux = {
-- 			-- ...
-- 		},
-- 	},
-- }
