local M = {}

M.cursor_marker = '<<cursor is here>>'

--- Convert the current buffer content to a single string
--- @param r number The line number (1-based)
--- @param c number The column number (0-based)
--- @return string The buffer content as a single string
function M.to_string(r, c)
  local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  if r < 1 then
    return ""
  end
  if r > #content then
    return ""
  end
  content[r] = content[r]:sub(1, c) .. M.cursor_marker .. content[r]:sub(c + 1)
  return table.concat(content, "\n")
end

return M
