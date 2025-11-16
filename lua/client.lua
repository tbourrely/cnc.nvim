local M = {}

local api_options = {
  url = 'http://localhost:11434/v1/chat/completions',
  model = 'codellama',
  max_tokens = 10,
  temperature = 0.2,
}

--- Fetch code completion from local LLM server
--- @param context string The code context to send to the LLM
--- @return string The completion text from the LLM
function M.get(context)
  local curl = require('plenary.curl')
  local result = curl.get(api_options.url, {
    headers = {
      ['Content-Type'] = 'application/json',
    },
    body = vim.json.encode({
      model = api_options.model,
      reasoning_effort = 'none',
      messages = {
        { role = 'developer', content = 'You need to complete the code from where cursor is you can not move your cursor elsewhere just start outputing what should be typed in Buffer content. you will be asked to complete the code part by part. Cursor position is marked by <<cursor is here>>:\n' },
        { role = 'user',      content = context },
      },
      max_tokens = api_options.max_tokens,
      temperature = api_options.temperature,
    }),
    method = 'POST',
  })

  if result.exit ~= 0 then
    vim.print('Error fetching completion: ' .. result.stderr)
    return ''
  end

  local decoded = vim.json.decode(result.body)
  local content = decoded.choices[1].message.content
  return content
end

return M
