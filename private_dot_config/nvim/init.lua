_G.Z = {}

-- ┌──────────────────────┐
-- │ Troubleshoot helpers │
-- └──────────────────────┘

--- Inspect `x`. Notify and log result.
--- @param x any
--- @param tag string?
--- @param level vim.log.levels?
Z.log = function(x, tag, level)
  level = level or vim.log.levels.INFO

  -- Check who calls this `log` function
  local info = debug.getinfo(2, 'Sl')
  local filename = info.source:match('([^/\\]+)$')
  local location = filename .. ':' .. info.currentline

  -- Show notification msg
  tag = tag and tag .. '=' or ''
  local msg = location .. ' ' .. tag .. vim.inspect(x)
  vim.notify(msg, level)

  -- Log msg to file
  local log_path = vim.env.HOME .. '/.nvim.log'
  local file, err = io.open(log_path, 'a+')
  if file == nil then
    vim.api.nvim_echo({ { 'Log() failed: ' .. err, 'ErrorMsg' } }, true, {})
    return
  end

  local timestamp = tostring(os.date('%Y-%m-%dT%H:%M:%S%Z'))
  file:write(timestamp .. ' ' .. msg .. '\n')
  file:close()
end

-- ┌─────────────────┐
-- │ Autocmd helpers │
-- └─────────────────┘

local gr = vim.api.nvim_create_augroup('custom-config', { clear = true })

Z.create_autocmd = function(event, pattern, callback, desc)
  local opts =
    { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end
