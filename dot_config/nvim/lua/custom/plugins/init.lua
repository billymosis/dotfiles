-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'sindrets/diffview.nvim',
  {
    'kawre/leetcode.nvim',
    build = ':TSUpdate html',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim', -- required by telescope
      'MunifTanjim/nui.nvim',

      -- optional
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      lang = 'typescript',
      -- configuration goes here
    },
  },
  { 'airblade/vim-rooter' },
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
      require('ts_context_commentstring').setup { enable_autocmd = false }
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end,
  },
  {
    'mickael-menu/zk-nvim',
    config = function()
      require('zk').setup {}
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
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = true,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 2 } },
        lualine_x = {},
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', color = { fg = '#61afef', bg = 'none', gui = 'italic,bold' } } },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },

      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', color = { fg = 'gray', bg = 'none', gui = 'italic,bold' } } },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    version = '2.*',
    config = function()
      require('window-picker').setup()
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
  {
    'tpope/vim-fugitive',
  },
  {
    'ray-x/go.nvim',
    dependencies = { -- optional packages
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('go').setup()
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
  {
    'johmsalas/text-case.nvim',
    config = function()
      require('textcase').setup {}
    end,
  },
  -- {
  --   'mistweaverco/kulala.nvim',
  --   config = function()
  --     vim.filetype.add {
  --       extension = {
  --         ['http'] = 'http',
  --       },
  --     }
  --     local kulala = require 'kulala'
  --     kulala.setup {
  --       -- default_view, body or headers
  --       default_view = 'body',
  --       -- dev, test, prod, can be anything
  --       -- see: https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-8.0#environment-files
  --       default_env = 'dev',
  --       -- enable/disable debug mode
  --       debug = false,
  --       -- default formatters for different content types
  --       formatters = {
  --         json = { 'jq', '.' },
  --         xml = { 'xmllint', '--format', '-' },
  --         html = { 'xmllint', '--format', '--html', '-' },
  --       },
  --       -- default icons
  --       icons = {
  --         inlay = {
  --           loading = '⏳',
  --           done = '✅ ',
  --         },
  --         lualine = '🐼',
  --       },
  --       -- additional cURL options
  --       -- e.g. { "--insecure", "-A", "Mozilla/5.0" }
  --       additional_curl_options = {},
  --     }
  --     vim.keymap.set('n', '<leader>pr', kulala.run, { desc = 'Send HTTP [R]equest' })
  --     vim.keymap.set('n', '<leader>pt', kulala.toggle_view, { desc = '[T]oggle View headers/body' })
  --     vim.keymap.set('n', '<leader>pe', kulala.set_selected_env, { desc = 'Select [E]nvironment' })
  --   end,
  -- },

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
