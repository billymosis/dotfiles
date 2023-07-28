require('which-key').setup()

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local wk = require('which-key')

local telescope = require('telescope.builtin')

local mappings = {
  ['<leader>'] = {
    -- utils used frequently
    e = { ':NvimTreeToggle<CR>', 'toggle nvimtree' },
    -- LSP and formatting related
    l = {
      d = { ':silent %!prettier --stdin-filepath --single-quote --trailing-comma all %<CR>', 'prettier' },
      e = { vim.diagnostic.open_float, 'open current diagnostic' },
      q = { vim.diagnostic.setloclist, 'diagnostic list' },
      f = { ':Format<CR>', 'format code' },
    },

    r = {
      function()
        local path = vim.fn.getcwd()
        local command = path .. '/run.sh'
        io.popen(command)
      end, 'Run ./run.sh on root project' },

    -- Git related
    h = {
      s = { 'stage hunk' },
      r = { 'reset hunk' },
      S = { 'stage buffer' },
      u = { 'undo stage hunk' },
      R = { 'reset buffer' },
      p = { 'preview hunk' },
      b = { 'blame line' },
      d = { 'diff this' },
      D = { 'diff this ~' },
      t = { 'toggle blame line' },
      q = { 'toggle deleted' }
    },

    ['<space>'] = { telescope.buffers, 'buffer list' },

    s = {
      f = { function()
        telescope.find_files { previewer = false }
      end, 'find file' },
      b = { function()
        telescope.current_buffer_fuzzy_find {}
      end, 'find text in current buffer' },
      d = { function() telescope.grep_string {} end, 'grep string' },
      t = { function() telescope.live_grep {} end, 'grep text current project' },
      o = { function() telescope.tags { only_current_buffer = true } end, 'tags' },
      n = { ':ObsidianSearch<CR>', 'Obsidan Note' },
    },
    ['?'] = { function() telescope.oldfiles {} end, 'old files' },

    -- Toggler
    z = { ':set wrap!<CR>', 'toggle wrap' },
    q = { ':ToggleTerm<CR>', 'toggle terminal' },
  },
  -- Diagnostic
  [']'] = {
    c = { 'next hunk' },
    d = { vim.diagnostic.goto_next, 'next diagnostic' }
  },
  ['['] = {
    c = { 'previous hunk' },
    d = { vim.diagnostic.goto_prev, 'previous diagnostic' }
  }
}
wk.register(mappings)

local M = {}

function M.setMap(client, opts)

	vim.g.inlay_hints_visible = false

	local function toggle_inlay_hints()
		if vim.g.inlay_hints_visible then
			vim.g.inlay_hints_visible = false
			vim.lsp.inlay_hint(opts.buffer, false)
		else
			if client.server_capabilities.inlayHintProvider then
				vim.g.inlay_hints_visible = true
				vim.lsp.inlay_hint(opts.buffer, true)
			else
				print("no inlay hints available")
			end
		end
	end

  vim.api.nvim_buf_create_user_command(opts.buffer, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })

	local bufopts = { noremap = true, silent = true, buffer = opts.buffer }

	vim.keymap.set(
		"n",
		"<leader>l1",
		toggle_inlay_hints,
		vim.tbl_extend("force", bufopts, { desc = "✨lsp toggle inlay hints" })
	)

	vim.keymap.set(
		"n",
		"<leader>l2",
		':set rnu!<CR>',
		vim.tbl_extend("force", bufopts, { desc = "toggle number" })
	)

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-BS>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
end

function M.set_lsp_key(client, bufnr)
  local opts = { buffer = bufnr }
  M.setMap(client, opts)
end

function M.set_gitsigns_key(bufnr)
  local gs = package.loaded.gitsigns

  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  -- Navigation
  map('n', ']c', function()
    if vim.wo.diff then return ']c' end
    vim.schedule(function() gs.next_hunk() end)
    return '<Ignore>'
  end, { expr = true })

  map('n', '[c', function()
    if vim.wo.diff then return '[c' end
    vim.schedule(function() gs.prev_hunk() end)
    return '<Ignore>'
  end, { expr = true })

  -- Actions
  map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
  map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
  map('n', '<leader>hS', gs.stage_buffer)
  map('n', '<leader>hu', gs.undo_stage_hunk)
  map('n', '<leader>hR', gs.reset_buffer)
  map('n', '<leader>hp', gs.preview_hunk)
  map('n', '<leader>hb', function() gs.blame_line { full = true } end)
  map('n', '<leader>tb', gs.toggle_current_line_blame)
  map('n', '<leader>hd', gs.diffthis)
  map('n', '<leader>hD', function() gs.diffthis('~') end)
  map('n', '<leader>td', gs.toggle_deleted)

  -- Text object
  map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end

return M
