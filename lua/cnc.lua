local M = {}

local autocmd = vim.api.nvim_create_autocmd
local delcmd = vim.api.nvim_del_autocmd
local suggestion = require('suggestion')
local log = require('log')
local uuid = require('uuid')

-- Store autocommand ids to clear them later
local commands = {}
-- Store the last request id to handle outdated responses
local last_request_id = nil

function M.setup()
  table.insert(commands, autocmd('CursorHoldI', {
    pattern = '*',
    callback = function()
      M.draw()
    end,
  }))

  table.insert(commands, autocmd('CursorMovedI', {
    pattern = '*',
    callback = function()
      M.reject_suggestion()
    end,
  }))

  table.insert(commands, autocmd('TextChangedI', {
    pattern = '*',
    callback = function()
      M.reject_suggestion()
    end,
  }))

  table.insert(commands, autocmd('ModeChanged', {
    pattern = '*',
    callback = function()
      M.reject_suggestion()
    end,
  }))

  vim.api.nvim_create_user_command('CncDisable', function()
    M.teardown()
  end, {})

  -- TODO: make this configurable
  vim.keymap.set('i', '<C-a>', function()
    M.accept_suggestion()
  end, { noremap = true, silent = true })

  vim.keymap.set('i', '<C-e>', function()
    M.reject_suggestion()
  end, { noremap = true, silent = true })
end

function M.teardown()
  for _, cmd_id in ipairs(commands) do
    delcmd(cmd_id)
  end
  commands = {}
  M.reject_suggestion()
end

local function get_cursor_position()
  local api = vim.api
  local line_num, col_num = unpack(api.nvim_win_get_cursor(0))
  return line_num, col_num
end

--- Draw code completion suggestion at the current cursor position
--- @return nil
function M.draw()
  local uv = vim.uv
  local line_num, col_num = get_cursor_position()
  local buffer_content = require('buffer').to_string(line_num, col_num)

  local function work_callback(content, id)
    require('log').debug('Requesting code completion from LLM with id ' .. id) -- must use require here as it runs in a separate thread
    return require('openai').get(content), id
  end
  local function after_work_callback(c, id)
    if id == nil then
      log.debug('No request id received in after_work_callback')
      return
    end
    log.debug('Received response from LLM for id ' .. id)

    if not c or c == '' then
      log.debug('No suggestion received from LLM for request id ' .. id)
      return
    end

    if last_request_id ~= id then
      log.debug('Discarding suggestion for outdated request id ' .. id)
      return
    end

    vim.schedule(function()
      log.debug('Drawing suggestion at line ' .. line_num .. ', column ' .. col_num .. ' for request id ' .. id)
      suggestion.draw_suggestion(c, line_num, col_num)
    end)
  end

  -- Generate a unique ID for this request,
  -- this helps in identifying outdated responses
  -- in case multiple requests are made in quick succession.
  local id = uuid.string()
  local work = uv.new_work(work_callback, after_work_callback)
  work:queue(buffer_content, id)
  last_request_id = id
end

--- Accept the current suggestion and insert it into the buffer
--- @return nil
function M.accept_suggestion()
  suggestion.accept_suggestion()
end

--- Reject the current suggestion and clear it from the buffer
--- @return nil
function M.reject_suggestion()
  suggestion.reject_suggestion()
end

return M
