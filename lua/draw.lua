local M = {}

-- Store extmark ids to clear them later
local mark_ids = {}
local marks_ns = 'cnc.nvim'

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

--- Draw a suggestion at the given line and column number
--- @param suggestion string The suggestion text to draw
--- @param line_num number The line number (1-based)
--- @param col_num number The column number (0-based)
--- @return nil
function M.draw_suggestion(suggestion, line_num, col_num)
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

return M
