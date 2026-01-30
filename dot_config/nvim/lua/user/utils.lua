-- Command: :GrepAnd <term1> <term2>
-- Example: :GrepAnd <div <Styled
vim.api.nvim_create_user_command("Qga", function(opts)
	local args = vim.split(opts.args, " ")
	if #args < 2 then
		print("Usage: :GrepAnd <term1> <term2>")
		return
	end

	local term1 = args[1]
	local term2 = args[2]

	-- The Logic: Find files with Term1, pipe them to find Term2
	-- We use 'rg -l' (filenames only) because we just want the files
	local cmd = string.format("rg -l '%s' | xargs rg -l '%s'", term1, term2)

	-- Run the command and get output lines
	local output = vim.fn.systemlist(cmd)

	if #output == 0 then
		print("No files found containing both: " .. term1 .. " + " .. term2)
		return
	end

	-- Convert filenames to Quickfix items
	local qf_items = {}
	for _, file in ipairs(output) do
		table.insert(qf_items, {
			filename = file,
			text = "Contains both terms",
			lnum = 1, -- Default to line 1 since we don't have exact locations
			col = 1,
		})
	end

	-- Set the Quickfix list and open it
	vim.fn.setqflist(qf_items)
	vim.cmd("copen")
	print("Found " .. #output .. " files.")
end, { nargs = "*" })

-- Populate a Vertical Split with full content of all files in the Quickfix List
vim.api.nvim_create_user_command("Qc", function()
	local qf_list = vim.fn.getqflist()
	local seen_files = {}
	local output = {}

	if #qf_list == 0 then
		print("Quickfix list is empty!")
		return
	end

	-- 1. Build the content
	for _, item in ipairs(qf_list) do
		local bufnr = item.bufnr
		local filename = vim.api.nvim_buf_get_name(bufnr)

		-- Deduplicate files
		if filename ~= "" and not seen_files[filename] then
			seen_files[filename] = true

			-- Get relative path for cleaner context
			local rel_path = vim.fn.fnamemodify(filename, ":.")

			-- Header
			table.insert(output, "--------------------------------------------------------------------------------")
			table.insert(output, "File: " .. rel_path)
			table.insert(output, "--------------------------------------------------------------------------------")

			-- Read file content safely
			if vim.fn.filereadable(filename) == 1 then
				local lines = vim.fn.readfile(filename)
				for _, line in ipairs(lines) do
					table.insert(output, line)
				end
			else
				table.insert(output, "<< File not readable >>")
			end

			table.insert(output, "") -- Spacer line
		end
	end

	-- 2. Open a new Vertical Split
	vim.cmd("vnew")

	-- 3. Get the new buffer ID
	local buf = vim.api.nvim_get_current_buf()

	-- 4. Paste the content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

	-- 5. Set Buffer Options (Scratch buffer behavior)
	vim.bo[buf].buftype = "nofile" -- Don't save to disk by default
	vim.bo[buf].bufhidden = "wipe" -- Clear RAM when closed
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "markdown" -- Syntax highlighting for readability

	print("Context dump created in new split!")
end, {})

-- Command: :TreeToBuf [depth]
-- Example: :TreeToBuf 2
vim.api.nvim_create_user_command("Qt", function(opts)
	-- Default depth to 3 if not provided
	local depth = opts.args ~= "" and opts.args or "3"

	-- The Command:
	-- 1. -I 'pattern': Ignore node_modules, git, build folders, coverage, etc.
	-- 2. --dirsfirst: Sorts folders on top (easier for AI to read)
	-- 3. -L n: Limits depth
	-- Uses git to list files, structured as a tree
	local cmd = "git ls-files | tree --fromfile -L " .. depth

	-- Execute and capture output
	local output = vim.fn.systemlist(cmd)

	-- Check if 'tree' is actually installed
	if vim.v.shell_error ~= 0 then
		print("Error: 'tree' command not found or failed. Do you have it installed?")
		return
	end

	-- 1. Open new Vertical Split
	vim.cmd("vnew")
	local buf = vim.api.nvim_get_current_buf()

	-- 2. Add a Header for context
	local header = {
		"# Project Structure",
		"Generated with: " .. cmd,
		"--------------------------------------------------",
		"",
	}

	-- Combine header and tree output
	local final_lines = vim.list_extend(header, output)

	-- 3. Set content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, final_lines)

	-- 4. Set Buffer Options (Scratchpad)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "markdown" -- Markdown rendering makes the tree look nice

	print("File tree generated in split!")
end, { nargs = "?" }) -- '?' means argument is optional

-- Command: :CopyQFLHunks [context_lines]
-- Example: :CopyQFLHunks 5 (Dumps matching line +/- 5 lines)
vim.api.nvim_create_user_command("Qch", function(opts)
	local context = tonumber(opts.args) or 3 -- Default to +/- 3 lines
	local qf_list = vim.fn.getqflist()
	local output = {}
	local last_file = ""

	if #qf_list == 0 then
		print("Quickfix list is empty!")
		return
	end

	for _, item in ipairs(qf_list) do
		local bufnr = item.bufnr
		local filename = vim.api.nvim_buf_get_name(bufnr)
		local lnum = item.lnum

		if filename ~= "" and lnum > 0 then
			-- 1. Read file if readable
			if vim.fn.filereadable(filename) == 1 then
				local all_lines = vim.fn.readfile(filename)

				-- 2. Calculate Range
				local start_line = math.max(1, lnum - context)
				local end_line = math.min(#all_lines, lnum + context)

				-- 3. Add Header (Only if file changed to keep it clean)
				if filename ~= last_file then
					table.insert(output, "--------------------------------------------------")
					table.insert(output, "File: " .. vim.fn.fnamemodify(filename, ":."))
					table.insert(output, "--------------------------------------------------")
					last_file = filename
				end

				-- 4. Add Snippet Header
				table.insert(output, string.format("... (Lines %d-%d) ...", start_line, end_line))

				-- 5. Insert Lines
				for i = start_line, end_line do
					table.insert(output, all_lines[i])
				end
				table.insert(output, "") -- Spacer
			end
		end
	end

	-- Output to Split Buffer
	vim.cmd("vnew")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
	vim.bo[buf].buftype = "nofile" -- Don't save to disk by default
	vim.bo[buf].bufhidden = "wipe" -- Clear RAM when closed
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "markdown" -- or 'javascript' for syntax highlighting
	print("Snippets dumped!")
end, { nargs = "?" })

-- Global (or file-local) variable to track the temporary context buffer
local llm_context_buf = nil

-- Helper: Get or Create the Context Buffer
local function get_context_buf()
	-- 1. Check if buffer exists and is valid in memory
	if llm_context_buf and vim.api.nvim_buf_is_valid(llm_context_buf) then
		-- 2. Check if it is currently visible in any window
		if vim.fn.bufwinid(llm_context_buf) == -1 then
			-- It exists but is hidden. Open a vertical split and set it to this buffer.
			vim.cmd("vsplit")
			vim.api.nvim_win_set_buf(0, llm_context_buf)

			-- Return focus to the original window
			vim.cmd("wincmd p")
		end
		return llm_context_buf
	end

	-- 3. Create new vertical split (Buffer didn't exist or was wiped)
	vim.cmd("vnew")
	llm_context_buf = vim.api.nvim_get_current_buf()

	-- Set Buffer Options (Scratchpad)
	vim.bo[llm_context_buf].buftype = "nofile"
	vim.bo[llm_context_buf].bufhidden = "hide" -- Keep content when buffer is hidden
	vim.bo[llm_context_buf].swapfile = false
	vim.bo[llm_context_buf].filetype = "markdown"
	-- Optional: Wrap text for better readability
	vim.wo.wrap = true

	-- Return focus to the original window
	vim.cmd("wincmd p")

	return llm_context_buf
end

-- Helper: Append lines to the context buffer
local function append_to_context(lines)
	local buf = get_context_buf()

	-- Get current line count to append at the end
	local line_count = vim.api.nvim_buf_line_count(buf)

	-- Add a separator if the buffer isn't empty
	if line_count > 1 then
		table.insert(lines, 1, "")
		table.insert(lines, 2, "---")
		table.insert(lines, 3, "")
	end

	vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
	print("Added to LLM Context Buffer")
end

-- Command 1: Qs (Query Snippet)
-- Logic: If Visual -> Code + Ref. If Normal -> Ref Only.
vim.api.nvim_create_user_command("Qs", function(opts)
	local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
	local filetype = vim.bo.filetype
	local output = {}

	-- opts.count comes from 'range'.
	-- In user commands, -range=0 means default is 0.
	-- If user selects visual, count > 0.
	if opts.count > 0 then
		-- VISUAL MODE DETECTED
		local start_line = opts.line1
		local end_line = opts.line2

		-- Get the selected lines
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

		-- Format Output
		table.insert(output, "File: " .. filename .. " (Lines " .. start_line .. "-" .. end_line .. ")")
		table.insert(output, "```" .. filetype)
		for _, line in ipairs(lines) do
			table.insert(output, line)
		end
		table.insert(output, "```")
	else
		-- NORMAL MODE (No selection)
		local curr_line = vim.fn.line(".")
		table.insert(output, "File Reference: " .. filename .. " (Line " .. curr_line .. ")")
	end

	append_to_context(output)
end, { range = 0 }) -- range=0 allows us to detect if a range was actually sent

-- Command 2: Ql (Query Location)
-- Logic: Always just Filename + Line Number (Visual range or Cursor)
vim.api.nvim_create_user_command("Ql", function(opts)
	local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
	local output = {}

	if opts.count > 0 then
		-- Range provided
		table.insert(output, "File Reference: " .. filename .. " (Lines " .. opts.line1 .. "-" .. opts.line2 .. ")")
	else
		-- Current cursor
		table.insert(output, "File Reference: " .. filename .. " (Line " .. vim.fn.line(".") .. ")")
	end

	append_to_context(output)
end, { range = 0 })
