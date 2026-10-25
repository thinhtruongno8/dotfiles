vim.api.nvim_create_user_command('Cd', function(opts)
  local markers = { '.git', 'Makefile' }

  -- arg parse
  local target = 'current'
  if #opts.fargs > 0 then target = opts.fargs[1] end
  if not vim.tbl_contains({ 'current', 'project' }, target) then
    vim.notify(
      "arg must be 'current', 'project' or empty",
      vim.log.levels.ERROR
    )
    return
  end

  local curr_file = vim.api.nvim_buf_get_name(0)
  if curr_file == '' or not vim.uv.fs_stat(curr_file) then
    vim.notify('current buffer is not a normal file', vim.log.levels.ERROR)
    return
  end

  -- locate nearest parent of current file
  local dir = vim.fs.dirname(curr_file)
  if target == 'current' then
    vim.fn.chdir(dir)
    vim.notify('cd to current dir: ' .. dir)
    return
  end

  -- locate project directory of current file
  local marker_files = vim.fs.find(markers, { path = dir, upward = true })
  if #marker_files > 0 then dir = vim.fs.dirname(marker_files[1]) end

  vim.notify('cd to project dir: ' .. dir)
  vim.fn.chdir(dir)
end, {
  nargs = '?',
  complete = function() return { 'project', 'current' } end,
})

vim.api.nvim_create_user_command('Run', function()
  if vim.env.TMUX == nil or vim.env.TMUX == '' then
    vim.notify('run: failed. Not in tmux')
    return
  end
  local count = vim.fn.system('tmux list-panes | wc -l')
  if tonumber(count) < 2 then
    if vim.api.nvim_win_get_width(0) > 125 then
      vim.fn.system('tmux splitw -h -l 60')
    else
      vim.fn.system('tmux splitw -v -l 15')
    end
  end
  local cmd = 'make'
  vim.system({ 'tmux', 'send-keys', '-t', ':.2', cmd, 'Enter' })
  vim.notify('run: ok. ' .. cmd)
end, {})
