local M = {}

-- TODO: Make these configurable
local api_options = {
  url = 'http://localhost:11434/v1/chat/completions',
  model = 'codellama',
  max_tokens = 10,
  temperature = 0.2,
}

--- Make a curl request
--- @param url string The URL to request
--- @param method string The HTTP method (e.g., "POST", "GET")
--- @param headers table A table of headers (key-value pairs)
--- @param body string The request body
--- @return string | nil The response body
local function curl_request(url, method, headers, body)
  local cmd = "curl -s"
  if method then
    cmd = cmd .. " -X " .. method
  end
  if headers then
    for key, value in pairs(headers) do
      cmd = cmd .. " -H '" .. key .. ": " .. value .. "'"
    end
  end
  if body then
    cmd = cmd .. " -d '" .. body .. "'"
  end
  cmd = cmd .. " '" .. url .. "'"

  local handle = io.popen(cmd)
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  return result
end

--- Fetch code completion from local LLM server
--- @param context string The code context to send to the LLM
--- @return string The completion text from the LLM
function M.get(context)
  local payload = vim.json.encode({
    model = api_options.model,
    reasoning_effort = 'none',
    messages = {
      -- TODO: improve system prompt
      { role = 'developer', content = 'You need to complete the code from where cursor is you can not move your cursor elsewhere just start outputing what should be typed in Buffer content. you will be asked to complete the code part by part. Cursor position is marked by <<cursor is here>>:\n' },
      { role = 'user',      content = context },
    },
    max_tokens = api_options.max_tokens,
    temperature = api_options.temperature,
  })

  local response = curl_request(
    api_options.url,
    "POST",
    { ["Content-Type"] = "application/json" },
    payload
  )

  if not response then
    return ""
  end

  local decoded = vim.json.decode(response)
  local content = decoded.choices[1].message.content
  return content
end

return M
