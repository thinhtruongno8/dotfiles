local function map(modes, lhs, rhs, desc, opts)
  modes = vim.split(modes, '')
  desc = desc or ''
  opts = opts or {}
  opts = vim.tbl_extend('force', opts, { desc = desc })
  vim.keymap.set(modes, lhs, rhs, opts)
end

Z.map = map

local function minifiles_open()
  local files = require('mini.files')
  local path = vim.api.nvim_buf_get_name(0)
  if not vim.uv.fs_stat(path) then path = files.get_latest_path() end
  if not files.close() then files.open(path) end
end

local function conform_format()
  local conform = require('conform')
  local first = vim
    .iter(conform.list_formatters(0))
    :find(function(f)
      return f.available == true
    end)
  if not first then
    vim.notify('no formatter available for this file', vim.log.levels.WARN)
    return
  end
  vim.notify('running format: ' .. first.name)
  conform.format({ async = false, lsp_format = 'fallback' })
  vim.notify('format done.')
end

map('i', '<C-c>', '<Esc>')
map('i', '<C-l>', '<Right>', 'Move cursor to the right')
map('n', '<Esc>', '<Cmd>nohlsearch<CR>', 'Stop search highlighting')
map('t', '<Esc><Esc>', '<C-\\><C-n>', 'Escape terminal mode')

map('nv', '<leader>d', '"+d')
map('nv', '<leader>d', '"+d')
map('nv', '<leader>D', '"+D')
map('nv', '<leader>D', '"+D')
map('nv', '<leader>y', '"+y')
map('nv', '<leader>Y', '"+Y')

map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', '<C-n>', '<Cmd>cnext<CR>zz')
map('n', '<C-p>', '<Cmd>cprev<CR>zz')

map('x', '>', '>gv', 'shift lines right nonstop')
map('x', '<', '<gv', 'shift lines left nonstop')

map('n', '[e', '<Cmd>move--v:count1<CR>')
map('n', ']e', '<Cmd>move+v:count1<CR>')

map('n', '<leader>q', vim.diagnostic.open_float, 'diag open float')

map('n', '<C-q>', '<C-w><C-q>', 'close window')
map('n', '<C-h>', '<C-w><C-w>', 'cycle through windows')

map('x', 'z/', '<C-\\><C-n>`</\\%V', 'Search forward within selection')
map('x', 'z?', '<C-\\><C-n>`>?\\%V', 'Search backward within selection')

map('n', '<leader>cd', '<Cmd>Cd project<CR>', 'cd to project dir')
map('n', '<leader>cc', '<Cmd>Cd current<CR>', 'cd to current dir')

map('n', '<leader>r', '<Cmd>Run<CR>', 'split tmux panes and run stuff')

-- plugin: mini.surround
map('n', 'yss', 'ys_', 'Add surrounding linewise', { remap = true })

-- plugin: MiniPick and MiniExtra
map('n', 'grd', "<Cmd>Pick lsp scope='definition'<CR>")
map('n', 'gri', "<Cmd>Pick lsp scope='implementation'<CR>")
map('n', 'grr', "<Cmd>Pick lsp scope='references'<CR>")
map('n', 'grt', "<Cmd>Pick lsp scope='type_definition'<CR>")
map('n', 'gO', "<Cmd>Pick lsp scope='document_symbol'<CR>")
map('n', 'gW', "<Cmd>Pick lsp scope='workspace_symbol_live'<CR>")

-- stylua: ignore start
map('n', '<leader> ',  '<Cmd>Pick files<CR>')
map('n', '<leader>fh', '<Cmd>Pick help<CR>')
map('n', '<leader>fk', '<Cmd>Pick keymaps<CR>')
map('n', '<leader>fb', '<Cmd>Pick buffers<CR>')
map('n', '<leader>fr', '<Cmd>Pick resume<CR>')
map('n', '<leader>fg', '<Cmd>Pick grep_live<CR>')
-- stylua: ignore end

map('n', '<leader>fp', '<Cmd>Pick projects<CR>')
map('n', '<leader>,', '<Cmd>Pick dotfiles<CR>', 'pick dotfiles')
map('n', '<leader>fm', '<Cmd>lua MiniNotify.show_history()<CR>')

-- plugin: MiniFiles
map('n', '<leader>e', minifiles_open)

map('n', '<leader>bq', vim.diagnostic.setqflist, 'diag set qflist')

-- plugin: hedyhli/outline.nvim
map('n', '<leader>bo', '<Cmd>Outline<CR>', 'show doc outline')

-- plugin: stevearc/conform.nvim
map('n', '<leader>bf', conform_format, 'conform format')

-- plugin: MeanderingProgrammer/render-markdown.nvim
map('n', '<leader>bm', '<Cmd>RenderMarkdown toggle<CR>', 'conform format')

-- plugin: andyg/leap.nvim
map('nxo', 's', '<Plug>(leap)', 'leap')

-- plugin: kevinhwang91/nvim-ufo
-- stylua: ignore start
map('n', 'zR', function() require('ufo').openAllFolds() end, 'openAllFolds')
map('n', 'zM', function() require('ufo').closeAllFolds() end, 'closeAllFolds')
-- stylua: ignore end

-- Git
-- plugin: vimfugitive and gitsigns
-- stylua: ignore start
map('n',  '<leader>gg', '<cmd>Git<CR>',                                'open vimfugitive')
map('n',  '<leader>gq', '<Cmd>Gitsigns setqflist<CR>',                 'git to qf')
map('n',  '<leader>gi', '<Cmd>Gitsigns preview_hunk_inline<CR>',       'git preview hunk inline')
map('n',  '<leader>gp', '<Cmd>Gitsigns preview_hunk<CR>',              'git preview hunk')
map('n',  '<leader>gp', '<Cmd>Gitsigns preview_hunk<CR>',              'git preview hunk')
map('nx', '<leader>g-', '<Cmd>Gitsigns stage_hunk<CR>',                'git toggle hunk')
map('nx', '<leader>gr', '<Cmd>Gitsigns reset_hunk<CR>',                'git reset hunk')
map('n',  ']h',         '<Cmd>Gitsigns nav_hunk next<CR>',             'git next hunk')
map('n',  '[h',         '<Cmd>Gitsigns nav_hunk prev<CR>',             'git prev hunk')
map('n',  '<leader>gb', '<Cmd>Gitsigns blame<CR>',                     'git blame buffer')
map('n',  '<leader>gB', '<Cmd>Gitsigns toggle_current_line_blame<CR>', 'git blame line')
-- stylua: ignore end
