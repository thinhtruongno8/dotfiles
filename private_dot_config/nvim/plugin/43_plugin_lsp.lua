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
