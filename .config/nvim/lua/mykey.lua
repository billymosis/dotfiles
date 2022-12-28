require('which-key').setup()

local map = vim.keymap.set

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

local wk = require('which-key')

local telescope = require('telescope.builtin')
--[[ local bm = require('buffer_manager.ui') ]]
local keys = '1234567890'
--[[ for i = 1, #keys do ]]
--[[   local key = keys:sub(i, i) ]]
--[[   map( ]]
--[[     'n', ]]
--[[     string.format('<leader>%s', key), ]]
--[[     function() require("buffer_manager.ui").nav_file(i) end, ]]
--[[     {} ]]
--[[   ) ]]
--[[ end ]]

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

    -- harpoon
    --[[ ['<space>'] = { bm.toggle_quick_menu, 'buffer list' }, ]]

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
    },
    ['?'] = { function() telescope.oldfiles {} end, 'old files' },

    -- Diagnostic
  },
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

function M.setMap(opts)
  vim.api.nvim_buf_create_user_command(opts.buffer, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
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

function M.set_lsp_key(_, bufnr)
  local opts = { buffer = bufnr }
  M.setMap(opts)
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
