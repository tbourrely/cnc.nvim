local M = {}

M.logpath = "/tmp/cnc.nvim.log"

M.write = function(msg)
  local f = io.open(M.logpath, "a")
  if f then
    f:write(msg .. "\n")
    f:flush()
  end
end

function M.debug(msg)
  M.write("[cnc.nvim] - [debug] - " .. os.date("%c") .. " - " .. msg)
end

return M
