require('which-key').setup()

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

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

    ['<space>'] = {
      function ()
       telescope.buffers {}
      end, 'curent buffer' },
    s = {
      f = { function()
        telescope.find_files { previewer = false }
      end, 'find file' },
      b = { function ()
        telescope.current_buffer_fuzzy_find {}
      end  , 'find text in current buffer' },
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
