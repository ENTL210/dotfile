-- LaTeX through vimtex. Compiling needs a TeX distribution with latexmk:
--   Mac:     MacTeX (brew install --cask mactex-no-gui)
--   Windows: TeX Live, or MiKTeX plus Strawberry Perl (latexmk is a Perl script)
-- Tectonic is used instead when latexmk is missing and tectonic is installed.

return {
  "lervag/vimtex",
  lazy = false, -- vimtex must not be lazy loaded, its filetype setup would be skipped
  init = function()
    vim.g.vimtex_quickfix_mode = 0 -- show errors with \le instead of popping a window open
    vim.g.vimtex_quickfix_open_on_warning = 0

    if vim.fn.executable("latexmk") == 0 and vim.fn.executable("tectonic") == 1 then
      vim.g.vimtex_compiler_method = "tectonic"
    end

    if vim.g.remote then
      vim.g.vimtex_view_enabled = 0 -- no PDF viewer over ssh
    elseif vim.fn.executable("sioyek") == 1 then
      vim.g.vimtex_view_method = "sioyek"
    elseif vim.g.is_mac and vim.fn.isdirectory("/Applications/Skim.app") == 1 then
      vim.g.vimtex_view_method = "skim" -- Skim jumps to the line you are editing
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
    elseif vim.g.is_windows and vim.fn.executable("SumatraPDF") == 1 then
      vim.g.vimtex_view_general_viewer = "SumatraPDF"
      vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
    else
      vim.g.vimtex_view_method = "general" -- the system's default PDF app
    end
  end,
}
