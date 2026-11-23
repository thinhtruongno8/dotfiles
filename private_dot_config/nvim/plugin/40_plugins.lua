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
  'https://github.com/lukas-reineke/indent-blankline.nvim',

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

-- ┌──────────────────────┐
-- │ colorscheme          │
-- └──────────────────────┘
Z.now(function()
  require('kanagawa').setup({
    compile = true,
    colors = { theme = { all = { ui = { bg_gutter = 'none' } } } },
  })

  vim.cmd.colorscheme('kanagawa')
end)

Z.now(
  function()
    require('snacks').setup({
      statuscolumn = { enabled = true },
    })
  end
)

-- ┌──────────────────────┐
-- │ mini.nvim            │
-- └──────────────────────┘
Z.now(
  function() require('mini.notify').setup({ lsp_progress = { enable = false } }) end
)

Z.now(function()
  require('mini.icons').setup()
  require('mini.icons').mock_nvim_web_devicons()
  require('mini.icons').tweak_lsp_kind()
end)

Z.now_if_args(function()
  require('mini.misc').setup()
  require('mini.misc').setup_restore_cursor()
end)

Z.now_if_args(
  function()
    require('mini.files').setup({
      mappings = {
        go_in_plus = 'l',
        synchronize = 'S',
      },
    })
  end
)

Z.later(function() require('mini.align').setup() end)

Z.later(
  function()
    require('mini.surround').setup({
      mappings = {
        add = 'ys',
        delete = 'ds',
        replace = 'cs',
        find = '',
        find_left = '',
        highlight = '',
      },
    })
  end
)

Z.later(function()
  local ai = require('mini.ai')
  ai.setup({
    n_lines = 10000,
    custom_textobjects = {
      F = ai.gen_spec.treesitter({
        a = '@function.outer',
        i = '@function.inner',
      }),
    },
  })
end)

Z.later(function() require('mini.splitjoin').setup() end)

Z.later(function()
  local active = function()
    local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 999 })
    local git = MiniStatusline.section_git({ trunc_width = 90 })
    local diff = MiniStatusline.section_diff({ trunc_width = 100 })
    local diagnostics =
      MiniStatusline.section_diagnostics({ trunc_width = 110 })
    local lsp = MiniStatusline.section_lsp({ trunc_width = 110 })
    local location = MiniStatusline.section_location({ trunc_width = 80 })
    local navic = ''

    -- breadcrumbs
    if
      package.loaded['nvim-navic']
      and require('nvim-navic').is_available()
      and not MiniStatusline.is_truncated(80)
    then
      navic = require('nvim-navic').get_location()
    end

    -- filename
    local filename = vim.bo.buftype == 'terminal' and '%t' or '%f%m%r'
    local filename_maxwid = vim.o.columns < 95 and '30' or ''
    filename = string.format('%%-00.%s(%s%%)', filename_maxwid, filename)

    return MiniStatusline.combine_groups({
      { hl = mode_hl, strings = { mode } },
      { hl = 'MiniStatuslineFileinfo', strings = { filename } },
      '%<', -- Mark general truncate point
      { hl = 'MiniStatuslineFilename', strings = { navic } },
      '%=', -- End left alignment
      {
        hl = 'MiniStatuslineFileinfo',
        strings = { diagnostics, lsp, diff, git },
      },
      { hl = mode_hl, strings = { location } },
    })
  end
  require('mini.statusline').setup({
    content = {
      active = active,
    },
  })
end)

Z.later(function()
  require('mini.pick').setup({
    mappings = {
      toggle_preview = '<M-p>',
      mark = '<Tab>',
      choose_marked = '<C-q>',
    },
  })

  require('mini.extra').setup({})

  MiniPick.registry.projects = function()
    return MiniPick.builtin.cli({ command = { 'tt' } })
  end

  MiniPick.registry.dotfiles = function()
    return MiniPick.builtin.files(
      {},
      { source = { cwd = vim.fn.expand('~/.local/share/chezmoi') } }
    )
  end
end)

-- ┌──────────────────────┐
-- │ LSP                  │
-- └──────────────────────┘
Z.later(function()
  require('mason').setup({})

  require('mason-lspconfig').setup({
    automatic_enable = {
      exclude = {},
      ensure_installed = {},
      automatic_installation = false,
    },
  })

  require('nvim-navic').setup({
    icons = { enabled = false },
    lsp = { auto_attach = true },
    depth_limit = 5,
  })

  require('lazydev').setup({
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = 'snacks.nvim', words = { 'Snacks' } },
    },
  })
end)

-- ┌──────────────────────┐
-- │ Autocomplete         │
-- └──────────────────────┘
Z.later(
  function()
    require('blink.cmp').setup({
      signature = { enabled = true },
      cmdline = { enabled = false },
      keymap = {
        ['<Tab>'] = false,
        ['<S-Tab>'] = false,
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
        ['<C-s>'] = { 'show_signature', 'hide_signature' },
      },
      sources = {
        per_filetype = {
          lua = { inherit_defaults = true, 'lazydev' },
        },
        providers = {
          lazydev = {
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      completion = {
        ghost_text = { enabled = false },
        list = { selection = { preselect = true, auto_insert = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
    })
  end
)

-- ┌──────────────────────┐
-- │ tree-sitter          │
-- └──────────────────────┘
Z.now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  Z.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  local langs = {
    ['lua'] = 'lua',
    ['python'] = 'python',
    ['go'] = 'go',
    ['terraform'] = 'terraform',
    ['hcl'] = 'hcl',
    ['powershell'] = 'ps1',
    ['rust'] = 'rs',
  }

  require('nvim-treesitter').setup({})
  require('nvim-treesitter').install(vim.tbl_keys(langs))

  Z.create_autocmd('FileType', vim.tbl_values(langs), function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end, 'setup treesitter')

  require('nvim-treesitter-textobjects').setup({})

  require('treesitter-context').setup({
    trim_scope = 'outer',
    mode = 'topline',
    max_lines = 5,
    min_window_height = 20,
  })
end)

-- ┌──────────────────────┐
-- │ Misc.                │
-- └──────────────────────┘
Z.now(function() require('guess-indent').setup({}) end)

Z.on_filetype('terminal', function()
  require('terminal').setup({})

  Z.create_autocmd(
    'FileType',
    'terminal',
    function() vim.wo.cocu = vim.wo.cocu .. 'v' end
  )
end)

Z.now_if_args(function()
  local ufo = require('ufo')
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  ufo.setup({})
end)

Z.later(
  function()
    require('outline').setup({ outline_window = { position = 'left' } })
  end
)

Z.later(
  function()
    require('conform').setup({
      notify_on_error = true,
      default_format_opts = {
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
      },
    })
  end
)

Z.later(function()
  vim.g.diffs = {
    integrations = {
      fugitive = true,
      gitsigns = true,
    },
  }

  require('gitsigns').setup({
    sign_priority = 20,
  })
end)

Z.later(function()
  local harpoon = require('harpoon')
  harpoon:setup()

  Z.map('n', '<leader>a', function() harpoon:list():add() end)
  Z.map(
    'n',
    '<leader>h',
    function() harpoon.ui:toggle_quick_menu(harpoon:list()) end
  )

  for i = 1, 9 do
    Z.map('n', '<leader>' .. i, function() harpoon:list():select(i) end)
  end
end)

Z.on_filetype(
  'markdown',
  function()
    require('render-markdown').setup({
      enabled = false,
      anti_conceal = { disabled_modes = { 'n' } },
    })
  end
)

Z.now(function()
  require('tiny-inline-diagnostic').setup({
    -- options = {
    --   multilines = {
    --     enabled = true,
    --     always_show = true,
    --   }
    -- }
  })
  vim.diagnostic.config({ virtual_text = false })
end)

Z.later(function() require('quicker').setup() end)

Z.now(function()
  require('ibl').setup()
  local exclude_fts = require('ibl.config').default_config.exclude.filetypes
  require('ibl').overwrite({
    scope = {
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = vim.tbl_filter(
        function(ft) return ft ~= 'help' end,
        exclude_fts
      ),
    },
  })
end)
