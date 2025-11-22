local M = {}
local log = require('log')

local marks_ns = 'cnc.nvim'
local ns_id = vim.api.nvim_create_namespace(marks_ns)

--- Clear all suggestions from the current buffer
--- @return nil
function M.clear()
  log.debug("Schedule clearing suggestions")
  vim.schedule(function()
    log.debug("Clearing suggestions")
    vim.api.nvim_buf_del_extmark(0, ns_id, 1)
  end)
end

--- Draw a suggestion at the given line and column number
--- @param suggestion string The suggestion text to draw
--- @param line_num number The line number (1-based)
--- @param col_num number The column number (0-based)
--- @return nil
function M.draw_suggestion(suggestion, line_num, col_num)
  local api = vim.api
  local opts = {
    id = 1,
    virt_text = { { suggestion } },
    virt_text_pos = 'overlay',
  }
  api.nvim_buf_set_extmark(0, ns_id, line_num - 1, col_num, opts)
end

--- Accept the current suggestion and insert it into the buffer
--- @return nil
function M.accept_suggestion()
  local mark = vim.api.nvim_buf_get_extmark_by_id(0, ns_id, 1, { details = true })
  log.debug(vim.inspect(mark))
  if #mark == 0 then
    log.debug("No extmark found")
    return
  end
  local row, col, content = unpack(mark)
  if not content or not content.virt_text or #content.virt_text == 0 then
    log.debug("No virt_text found in extmark")
    return
  end
  local virt_text = content.virt_text[1][1]
  log.debug("Inserting suggestion at row " .. row .. ", col " .. col .. ": " .. virt_text)
  vim.api.nvim_buf_set_text(0, row, col, row, col, { virt_text })
end

--- Reject the current suggestion and clear it from the buffer
--- @return nil
function M.reject_suggestion()
  log.debug("Rejecting suggestion")
  M.clear()
end

return M
