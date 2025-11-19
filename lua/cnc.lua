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

local function get_cursor_position()
  local api = vim.api
  local line_num, col_num = unpack(api.nvim_win_get_cursor(0))
  return line_num, col_num
end

local function draw_suggestion(suggestion, line_num, col_num)
  local api = vim.api
  local bnr = vim.fn.bufnr('%')
  local ns_id = api.nvim_create_namespace(marks_ns)
  local opts = {
    id = 1,
    virt_text = { { suggestion } },
    virt_text_pos = 'overlay',
  }
  local mark_id = api.nvim_buf_set_extmark(bnr, ns_id, line_num - 1, col_num, opts)
  table.insert(mark_ids, mark_id)
end

--- Draw code completion suggestion at the current cursor position
--- @return nil
---
--- TODO:
--- * improve cursor position handling
function M.draw()
  local uv = vim.uv

  local line_num, col_num = get_cursor_position()
  local buffer_content = require('buffer').to_string(line_num, col_num)

  local function work_callback(content)
    return require('client').get(content)
  end
  local function after_work_callback(c)
    if not c or c == '' then
      return
    end

    vim.schedule(function()
      draw_suggestion(c, line_num, col_num)
    end)
  end

  -- TODO: handle multiple requests properly (cancellation, queueing, etc.)
  local work = uv.new_work(work_callback, after_work_callback)
  work:queue(buffer_content)
end

return M
