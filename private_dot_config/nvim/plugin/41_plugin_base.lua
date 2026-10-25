local plugins = {
  -- core
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/folke/snacks.nvim',

  -- colorscheme
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/rebelot/kanagawa.nvim',

  -- qol
  'https://codeberg.org/andyg/leap.nvim',
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/hedyhli/outline.nvim',
  'https://github.com/stevearc/quicker.nvim',

  'https://github.com/nvim-lua/plenary.nvim',
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },

  'https://github.com/saghen/blink.indent',
  'https://github.com/norcalli/nvim-terminal.lua',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/rachartier/tiny-inline-diagnostic.nvim',

  -- fold like vscode
  'https://github.com/kevinhwang91/nvim-ufo',
  'https://github.com/kevinhwang91/promise-async',

  -- git
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/barrettruth/diffs.nvim',

  -- autoformat
  'https://github.com/stevearc/conform.nvim',

  -- autocomplete
  'https://github.com/rafamadriz/friendly-snippets',
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.10.2' },

  -- lsp
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/SmiteshP/nvim-navic',
  'https://github.com/folke/lazydev.nvim',

  -- treesitter
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    version = 'main',
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
    version = 'master',
  },
}

vim.pack.add(plugins)

local misc = require('mini.misc')
Z.now = function(f) misc.safely('now', f) end
Z.later = function(f) misc.safely('later', f) end
Z.now_if_args = vim.fn.argc(-1) > 0 and Z.now or Z.later
Z.on_event = function(ev, f) misc.safely('event:' .. ev, f) end
Z.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end

Z.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
      return
    end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Z.create_autocmd('PackChanged', '*', f, desc)
end
