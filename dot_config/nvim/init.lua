-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost',
  {
    command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
    group = packer_group,
    pattern = 'init.lua'
  })

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager
  use 'numToStr/Comment.nvim'  -- "gc" to comment visual regions/lines
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'nvim-lualine/lualine.nvim' -- Fancier statusline
  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'
  -- Add git related info in the signs columns and popups
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  })
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- lsp
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-cmp'      -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'
  use {
    'j-hui/fidget.nvim',
    tag = 'legacy',
  }
  use 'simrat39/rust-tools.nvim'

  -- other
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    }
  }
  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'
  use 'airblade/vim-rooter'
  use 'tpope/vim-fugitive'
  use 'fatih/vim-go'
  use 'folke/which-key.nvim'
  use 'rebelot/kanagawa.nvim'
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically

  --[[ use 'epwalsh/obsidian.nvim' ]]
  use { '~/open_source/bc/obsidian.nvim', branch = 'new' }
  use { "akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end }
end)

local function noteDirectory()
  local date = os.date("*t")
  local monthNames = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December" }
  local monthName = monthNames[date.month]
  return string.format("%04d/%02d-%s/",
    date.year, date.month, monthName)
end

local function noteDateFormat(time)
  local date = tostring(os.date("%Y-%m-%d-%A", time))
  return date
end

require("obsidian").setup({
  dir = "~/OneDrive/note",
  daily_notes = {
    folder = noteDirectory(),
    format_date = function(time)
      return os.date("%Y%m%d", time) -- format: year, month and date
    end,
  },
  completion = {
    nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
  }
})

require('nvim-autopairs').setup()
require('nvim-ts-autotag').setup()

local mykey = require('mykey')

vim.o.clipboard = 'unnamedplus'
vim.wo.wrap = false

--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

--Enable mouse mode
vim.o.mouse = 'a'

--Enable break indent
vim.o.breakindent = true

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

--Set colorscheme

require('kanagawa').setup({
  transparent = true,
})

vim.o.termguicolors = true
vim.cmd [[colorscheme kanagawa]]
vim.cmd.highlight({ "LineNr", "guibg=none" })

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- set relative number
vim.o.relativenumber = true

-- set cursor
vim.opt.cursorline = true

--Set statusbar
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'kanagawa',
    component_separators = '|',
    section_separators = '',
    globalstatus = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_x = { { 'filename', path = 1 } },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
}

--Enable Comment.nvim
require('Comment').setup {
  pre_hook = function(ctx)
    local U = require 'Comment.utils'

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require('ts_context_commentstring.utils').get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require('ts_context_commentstring.utils').get_visual_start_location()
    end

    return require('ts_context_commentstring.internal').calculate_commentstring {
      key = ctx.ctype == U.ctype.line and '__default' or '__multiline',
      location = location,
    }
  end,
}

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

--Map blankline
vim.g.indent_blankline_char = '┊'
vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = mykey.set_gitsigns_key
}

-- Telescope
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native
require('telescope').load_extension 'fzf'

local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.5

require 'nvim-tree'.setup {
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  view = {
    adaptive_size = true,
    relativenumber = true,
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * WIDTH_RATIO
        local window_h = screen_h * HEIGHT_RATIO
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2)
            - vim.opt.cmdheight:get()
        return {
          border = "rounded",
          relative = "editor",
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
        }
      end,
    },
    width = function()
      return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
    end,
  }
}
-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'lua', 'python', 'rust', 'typescript', 'help', 'php', 'json', "markdown",
    "markdown_inline", 'bash', 'go' },
  autotag = {
    enable = true,
  },
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = { "markdown" },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

require('mason').setup()

local servers = { 'clangd', 'pyright', 'tsserver', 'intelephense', 'rust_analyzer', 'jsonls', 'bashls', 'eslint', 'gopls' }

require('mason-lspconfig').setup({
  ensure_installed = servers,
})

-- LSP settings
local lspconfig = require 'lspconfig'

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Enable the following language servers
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = mykey.set_lsp_key,
    capabilities = capabilities,
  }
end

lspconfig.tsserver.setup {
  --[[ init_options = { ]]
  --[[   maxTsServerMemory = 1024, ]]
  --[[   hostInfo = 'neovim-billy' ]]
  --[[ }, ]]
  on_attach =  mykey.set_lsp_key,
  capabilities = capabilities,
}

lspconfig.tailwindcss.setup {
  autostart = false,
  on_attach = mykey.set_lsp_key,
  capabilities = capabilities,
}

require('fidget').setup()

-- xample custom server
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.lua_ls.setup {
  on_attach = mykey.set_lsp_key,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

--[[ local rt = require("rust-tools") ]]

-- rust setup
--[[ rt.setup( ]]
--[[   { ]]
--[[     server = { ]]
--[[       on_attach = function(_, bufnr) ]]
--[[         local opts = { buffer = bufnr } ]]
--[[         mykey.setMap(opts) ]]
--[[ vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr }) ]]
--[[ vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr }) ]]
--[[       end, ]]
--[[     }, ]]
--[[   } ]]
--[[ ) ]]

-- tab title
function _G.current_tab()
  local curr_buf = vim.fn.bufnr()
  local total = 0
  local curr_tab

  for i = 1, vim.fn.tabpagenr('$') do
    total = total + 1
    for _, bufnr in ipairs(vim.fn.tabpagebuflist(i)) do
      if bufnr == curr_buf then
        curr_tab = i
      end
    end
  end

  return string.format('(%d of %d)', curr_tab, total)
end

vim.opt.titlestring = [[%f %h%m%r%w - %{v:progname} %{luaeval('current_tab()')}]]
