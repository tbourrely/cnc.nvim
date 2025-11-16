describe('Test buffer manipulation', function()
  local s = nil

  before_each(function()
    local content = {
      'line one',
      'line two',
      'line three',
    }
    s = stub(vim.api, 'nvim_buf_get_lines', function(_, _, _, _)
      return content
    end)
  end)

  after_each(function()
    if s then
      s:revert()
    end
  end)

  it('Should place marker after first letter', function()
    local buffer_content = require('buffer').to_string(1, 1)
    assert.are.same('l<<cursor is here>>ine one\nline two\nline three', buffer_content)
  end)

  it('Should place marker at first letter', function()
    local buffer_content = require('buffer').to_string(1, 0)
    assert.are.same('<<cursor is here>>line one\nline two\nline three', buffer_content)
  end)

  it('Should place marker at the end', function()
    local buffer_content = require('buffer').to_string(3, 10)
    assert.are.same('line one\nline two\nline three<<cursor is here>>', buffer_content)
  end)

  it('Should place marker in the middle of line', function()
    local buffer_content = require('buffer').to_string(2, 5)
    assert.are.same('line one\nline <<cursor is here>>two\nline three', buffer_content)
  end)

  it('Should handle out of bounds by an empty return value', function()
    local buffer_content = require('buffer').to_string(4, 1)
    assert.are.same('', buffer_content)
  end)
end)
