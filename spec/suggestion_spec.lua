describe('Test suggestions', function()
  local suggestion = require('suggestion')
  local vim = vim

  it('Should draw a suggestion', function()
    local s = stub(vim.api, 'nvim_buf_set_extmark', function(...) end)
    suggestion.draw_suggestion('suggested text', 1, 0)
    assert.stub(s).was.called(1)
    s:revert()
  end)

  it('Should accept a suggestion', function()
    local smark = stub(vim.api, 'nvim_buf_get_extmark_by_id', function(_, _, _, _)
      return { 0, 0, { virt_text = { { 'suggested text' } } } }
    end)
    local sset = stub(vim.api, 'nvim_buf_set_text', function(...) end)
    suggestion.accept_suggestion()
    assert.stub(smark).was.called(1)
    assert.stub(sset).was.called(1)
    smark:revert()
    sset:revert()
  end)

  it('Should not accept suggestion if none exists', function()
    local smark = stub(vim.api, 'nvim_buf_get_extmark_by_id', function(_, _, _, _)
      return {}
    end)
    local sset = stub(vim.api, 'nvim_buf_set_text', function(...) end)
    suggestion.accept_suggestion()
    assert.stub(smark).was.called(1)
    assert.stub(sset).was.not_called()
    smark:revert()
    sset:revert()
  end)

  it('Should accept suggestion with no text on line', function()
    local smark = stub(vim.api, 'nvim_buf_get_extmark_by_id', function(_, _, _, _)
      return { 0, 0, { virt_text = { { 'suggested text' } } } }
    end)
    local sget = stub(vim.api, 'nvim_buf_get_lines', function(_, _, _, _)
      return { '' }
    end)
    local sset = stub(vim.api, 'nvim_buf_set_text', function(...) end)
    local scursor = stub(vim.api, 'nvim_win_set_cursor', function(...) end)
    suggestion.accept_suggestion()
    assert.stub(smark).was.called(1)
    assert.stub(sset).was.called_with(0, 0, 0, 0, 0, { 'suggested text' })
    assert.stub(scursor).was.called_with(0, { 1, 14 }) -- 14 chars in 'suggested text'
    smark:revert()
    sset:revert()
    sget:revert()
    scursor:revert()
  end)

  it('Should replace existing text when accepting suggestion', function()
    local smark = stub(vim.api, 'nvim_buf_get_extmark_by_id', function(_, _, _, _)
      return { 0, 5, { virt_text = { { 'suggested text' } } } }
    end)
    local sget = stub(vim.api, 'nvim_buf_get_lines', function(_, _, _, _)
      return { 'super long text' }
    end)
    local sset = stub(vim.api, 'nvim_buf_set_text', function(...) end)
    suggestion.accept_suggestion()
    assert.stub(smark).was.called(1)
    assert.stub(sset).was.called_with(0, 0, 5, 0, 15, { 'suggested text' }) -- 15 chars in 'super long text'
    smark:revert()
    sset:revert()
    sget:revert()
  end)

  it('Should replace up to end of line when accepting suggestion', function()
    local smark = stub(vim.api, 'nvim_buf_get_extmark_by_id', function(_, _, _, _)
      return { 0, 5, { virt_text = { { 'suggested text' } } } }
    end)
    local sget = stub(vim.api, 'nvim_buf_get_lines', function(_, _, _, _)
      return { 'short' }
    end)
    local sset = stub(vim.api, 'nvim_buf_set_text', function(...) end)
    suggestion.accept_suggestion()
    assert.stub(smark).was.called(1)
    assert.stub(sset).was.called_with(0, 0, 5, 0, 5, { 'suggested text' }) -- 5 chars in 'short'
    smark:revert()
    sset:revert()
    sget:revert()
  end)

  it('Should replace when cursor is at middle of line', function()
    local smark = stub(vim.api, 'nvim_buf_get_extmark_by_id', function(_, _, _, _)
      return { 0, 6, { virt_text = { { 'suggested text' } } } }
    end)
    local sget = stub(vim.api, 'nvim_buf_get_lines', function(_, _, _, _)
      return { 'hello world ' }
    end)
    local sset = stub(vim.api, 'nvim_buf_set_text', function(...) end)
    local scursor = stub(vim.api, 'nvim_win_set_cursor', function(...) end)
    suggestion.accept_suggestion()
    assert.stub(smark).was.called(1)
    assert.stub(sset).was.called_with(0, 0, 6, 0, 12, { 'suggested text' }) -- 12 chars in 'hello world '
    assert.stub(scursor).was.called_with(0, { 1, 20 })                      -- 20 chars in 'hello suggested text'
    smark:revert()
    sset:revert()
    sget:revert()
    scursor:revert()
  end)

  it('Should clear suggestions', function()
    local sschedule = stub(vim, 'schedule', function(fn) fn() end)
    local s = stub(vim.api, 'nvim_buf_del_extmark', function(...) end)
    suggestion.reject_suggestion()
    assert.stub(s).was.called(1)
    s:revert()
    sschedule:revert()
  end)
end)
