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
