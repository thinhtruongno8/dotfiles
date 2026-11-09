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
    return MiniPick.builtin.files({ source = { cwd = '~/.local/share/chezmoi' } })
  end
end)
