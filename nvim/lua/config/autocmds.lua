local group = vim.api.nvim_create_augroup("user_defaults", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- reopen files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
