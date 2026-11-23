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

vim.api.nvim_create_user_command(
  'F',
  function() vim.fn.setreg('+', vim.fn.expand('%:p')) end,
  {}
)

--- given a filepath, return a source if it's a target and vice versa. Return an
--- empty string if current file is not managed by chezmoi.
--- @param path string
--- @param target_only boolean
--- @return string
--- @return 'source'|'target'|''
local function cm_get_src_or_target(path, target_only)
  -- f(i, y) -> '', ''
  -- f(i, n) -> '', ''
  -- f(s, y) -> t, 'target'
  -- f(s, n) -> t, 'target'
  -- f(t, y) -> t, 'target'
  -- f(t, n) -> s, 'source'

  local res = vim.system({ 'chezmoi', 'target-path', path }):wait(2000)
  if res.code == 0 then
    local target, _ = res.stdout:gsub('\n*', '')
    return target, 'target'
  end

  res = vim.system({ 'chezmoi', 'source-path', path }):wait(2000)
  if res.code ~= 0 then return '', '' end

  if target_only then return path, 'target' end

  local source, _ = res.stdout:gsub('\n*', '')
  return source, 'source'
end

vim.api.nvim_create_user_command('Cm', function()
  local curr_file = vim.fn.expand('%:p')
  local counter, counter_type = cm_get_src_or_target(curr_file, false)
  if counter_type == '' then
    vim.notify(curr_file .. ' not managed by chezmoi')
    return
  end

  vim.notify('opening (' .. counter_type .. ') ' .. counter)
  vim.cmd('e ' .. counter)
end, {})

vim.api.nvim_create_user_command('Cmdiff', function()
  local curr_file = vim.fn.expand('%:p')
  local counter, counter_type = cm_get_src_or_target(curr_file, false)
  if counter_type == '' then
    vim.notify(curr_file .. ' not managed by chezmoi')
    return
  end

  local cm_diff = { 'chezmoi', 'diff' }
  if counter_type == 'source' then
    cm_diff[#cm_diff + 1] = '--reverse'
    cm_diff[#cm_diff + 1] = curr_file
  else
    cm_diff[#cm_diff + 1] = counter
  end

  vim.notify(table.concat(cm_diff, ' '))
  vim.system(cm_diff, { text = true }, function(obj)
    if obj.code ~= 0 then
      vim.notify('Cmdiff error: ' .. obj.stderr)
      return
    end
    local lines = vim.split(obj.stdout or '', '\r?\n', { trimempty = true })
    vim.schedule(function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].filetype = 'diff'
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_set_current_buf(buf)
    end)
  end)
end, {})

vim.api.nvim_create_user_command('Cma', function()
  local curr_file = vim.fn.expand('%:p')
  local target, target_type = cm_get_src_or_target(curr_file, true)
  if target_type ~= 'target' then
    vim.notify(curr_file .. ' not managed by chezmoi')
    return
  end
  vim.notify('chezmoi apply ' .. target)
  vim.system({ 'chezmoi', 'apply', target }, { text = true }, function(obj)
    if obj.code ~= 0 then
      vim.notify('Cma error: ' .. obj.stderr)
      return
    end
  end)
end, {})

vim.api.nvim_create_user_command('Cmra', function()
  local curr_file = vim.fn.expand('%:p')
  local target, target_type = cm_get_src_or_target(curr_file, true)
  if target_type ~= 'target' then
    vim.notify(curr_file .. ' not managed by chezmoi')
    return
  end
  vim.notify('chezmoi re-add ' .. target)
  vim.system({ 'chezmoi', 're-add', target }, { text = true }, function(obj)
    if obj.code ~= 0 then
      vim.notify('Cmra error: ' .. obj.stderr)
      return
    end
  end)
end, {})
