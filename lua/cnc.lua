local M = {}

local autocmd = vim.api.nvim_create_autocmd
local delcmd = vim.api.nvim_del_autocmd

-- Store extmark ids to clear them later
local mark_ids = {}
local marks_ns = 'cnc.nvim'
-- Store autocommand ids to clear them later
local commands = {}

function M.setup()
  table.insert(commands, autocmd('CursorHoldI', {
    pattern = '*',
    callback = function()
      M.draw()
    end,
  }))

  table.insert(commands, autocmd('TextChangedI', {
    pattern = '*',
    callback = function()
      M.clear()
    end,
  }))

  table.insert(commands, autocmd('ModeChanged', {
    pattern = '*',
    callback = function()
      M.clear()
    end,
  }))

  vim.api.nvim_create_user_command('CncDisable', function()
    M.teardown()
  end, {})
end

function M.teardown()
  for _, cmd_id in ipairs(commands) do
    delcmd(cmd_id)
  end
  commands = {}
  M.clear()
end

function M.clear()
  local api = vim.api
  local bnr = vim.fn.bufnr('%')
  local ns_id = api.nvim_create_namespace(marks_ns)
  vim.schedule(function()
    for _, mark_id in ipairs(mark_ids) do
      api.nvim_buf_del_extmark(bnr, ns_id, mark_id)
    end
    mark_ids = {}
  end)
end

function M.draw()
  local api = vim.api
  local bnr = vim.fn.bufnr('%')
  local line_num, col_num = unpack(api.nvim_win_get_cursor(0))
  local ns_id = api.nvim_create_namespace(marks_ns)
  local client = require('client')
  local content = client.get(require('buffer').to_string(line_num, col_num))
  local opts = {
    id = 1,
    virt_text = { { content } },
    virt_text_pos = 'overlay',
  }
  vim.print(line_num, col_num)
  local mark_id = api.nvim_buf_set_extmark(bnr, ns_id, line_num - 1, col_num, opts)
  table.insert(mark_ids, mark_id)
end

return M
