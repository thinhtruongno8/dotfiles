Z.now_if_args(function() require('guess-indent').setup({}) end)

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
    require('blink.indent').setup({
      static = { char = '│' },
      scope = {
        char = '│',
        indent_at_cursor = true,
        highlights = { 'BlinkIndentScope' },
      },
    })
  end
)

Z.later(function()
  require('outline').setup({ outline_window = { position = 'left' } })
end)

Z.later(
  function()
    require('conform').setup({
      notify_on_error = true,
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

Z.later(function()
  require('tiny-inline-diagnostic').setup()
  vim.diagnostic.config({ virtual_text = false })
end)

Z.later(function() require('quicker').setup() end)
