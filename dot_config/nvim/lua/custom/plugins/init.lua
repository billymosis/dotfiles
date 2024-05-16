-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'alexghergh/nvim-tmux-navigation',
    config = function()
      -- TMUX
      local nvim_tmux_nav = require 'nvim-tmux-navigation'

      nvim_tmux_nav.setup {
        disable_when_zoomed = true, -- defaults to false
      }

      vim.keymap.set('n', '<C-h>', nvim_tmux_nav.NvimTmuxNavigateLeft)
      vim.keymap.set('n', '<C-j>', nvim_tmux_nav.NvimTmuxNavigateDown)
      vim.keymap.set('n', '<C-k>', nvim_tmux_nav.NvimTmuxNavigateUp)
      vim.keymap.set('n', '<C-l>', nvim_tmux_nav.NvimTmuxNavigateRight)
      vim.keymap.set('n', '<C-\\>', nvim_tmux_nav.NvimTmuxNavigateLastActive)
      vim.keymap.set('n', '<C-Space>', nvim_tmux_nav.NvimTmuxNavigateNext)
    end,
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      require('ts_context_commentstring').setup {}
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end,
  },
  {
    'mickael-menu/zk-nvim',
    config = function()
      require('zk').setup()
    end,
  },
  {
    'michaelrommel/nvim-silicon',
    lazy = true,
    cmd = 'Silicon',
    config = function()
      require('silicon').setup {
        font = 'JetBrainsMono NF=34;Noto Color Emoji=34',
        output = function()
          return '~/Pictures/Code' .. os.date '!%Y-%m-%dT%H-%M-%S' .. '.png'
        end,
        to_clipboard = true,
        pad_horiz = 0,
        pad_vert = 0,
        line_offset = function(args)
          return args.line1
        end,
        tab_width = 2,
        window_title = function()
          local full_path = vim.fn.expand '%:p'
          local relative_path = vim.fn.fnamemodify(full_path, ':~:.')
          local name = 'Bimo | '
          return name .. relative_path
        end,
      }
    end,
  },
  -- { 'windwp/nvim-autopairs' },
  -- { 'windwp/nvim-ts-autotag' },
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
      require('onedark').setup {}

      vim.cmd [[
        highlight Normal guibg=none
        highlight NonText guibg=none
        highlight Normal ctermbg=none
        highlight NonText ctermbg=none
        highlight EndOfBuffer guibg=NONE ctermbg=NONE
        highlight clear SignColumn
      ]]
    end,
  },
  -- {
  --   'kyazdani42/nvim-tree.lua',
  --   config = function()
  --     local HEIGHT_RATIO = 0.8
  --     local WIDTH_RATIO = 0.5
  --
  --     require('nvim-tree').setup {
  --       update_focused_file = {
  --         enable = true,
  --         update_cwd = true,
  --       },
  --       view = {
  --         adaptive_size = true,
  --         relativenumber = true,
  --         float = {
  --           enable = true,
  --           open_win_config = function()
  --             local screen_w = vim.opt.columns:get()
  --             local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
  --             local window_w = screen_w * WIDTH_RATIO
  --             local window_h = screen_h * HEIGHT_RATIO
  --             local window_w_int = math.floor(window_w)
  --             local window_h_int = math.floor(window_h)
  --             local center_x = (screen_w - window_w) / 2
  --             local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
  --             return {
  --               border = 'rounded',
  --               relative = 'editor',
  --               row = center_y,
  --               col = center_x,
  --               width = window_w_int,
  --               height = window_h_int,
  --             }
  --           end,
  --         },
  --         width = function()
  --           return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
  --         end,
  --       },
  --     }
  --   end,
  --   vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'toggle nvimtree' }),
  -- },
}
