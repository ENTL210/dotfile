return {
  "lervag/vimtex",
  ft = "tex",
  init = function()
    if not vim.g.remote then
      vim.g.vimtex_view_method = "general"
    end
  end,
}
