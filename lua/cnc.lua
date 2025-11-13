local M = {}

local autocmd = vim.api.nvim_create_autocmd

-- Store extmark ids to clear them later
local mark_ids = {}

function M.setup()
  autocmd('CursorHoldI', {
    pattern = '*',
    callback = function()
      M.draw()
    end,
  })

  autocmd('TextChangedI', {
    pattern = '*',
    callback = function()
      M.clear()
    end,
  })

  autocmd('ModeChanged', {
    pattern = '*',
    callback = function()
      M.clear()
    end,
  })
end

function M.clear()
  local api = vim.api
  local bnr = vim.fn.bufnr('%')
  local ns_id = api.nvim_create_namespace('demo')
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
  local r, c = unpack(api.nvim_win_get_cursor(0))
  local ns_id = api.nvim_create_namespace('demo')
  local line_num = r
  local col_num = c
  local opts = {
    id = 1,
    virt_text = { { "demo", "IncSearch" } },
    virt_text_pos = 'overlay',
  }
  print(line_num, col_num)
  local mark_id = api.nvim_buf_set_extmark(bnr, ns_id, line_num - 1, col_num, opts)
  table.insert(mark_ids, mark_id)
end

return M
