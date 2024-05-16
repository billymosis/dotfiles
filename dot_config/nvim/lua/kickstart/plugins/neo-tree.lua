-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>e', ':Neotree reveal<CR>', { desc = 'NeoTree reveal' } },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['<leader>e'] = 'close_window',
          ['h'] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' and node:is_expanded() then
              require('neo-tree.sources.filesystem').toggle_directory(state, node)
            else
              require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
            end
          end,
          ['l'] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              if not node:is_expanded() then
                require('neo-tree.sources.filesystem').toggle_directory(state, node)
              elseif node:has_children() then
                require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
              end
            end
          end,
        },
      },
    },
  },
}
