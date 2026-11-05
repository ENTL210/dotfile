vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- which machine are we on
vim.g.is_windows = vim.fn.has("win32") == 1
vim.g.is_mac = vim.fn.has("mac") == 1
-- true when connected over ssh (the OSU server); used to trim features below
vim.g.remote = vim.env.SSH_CONNECTION ~= nil

-- skip provider setup, it costs startup time and nothing here needs it
for _, p in ipairs({ "python3", "node", "ruby", "perl" }) do
  vim.g["loaded_" .. p .. "_provider"] = 0
end

-- .tex files are always LaTeX (never plain TeX)
vim.g.tex_flavor = "latex"

local o = vim.opt
o.number = true
o.mouse = "a"
o.signcolumn = "yes"
o.termguicolors = true
o.splitright = true
o.splitbelow = true
o.ignorecase = true
o.smartcase = true
o.wrap = false
o.scrolloff = 6
o.updatetime = 250
o.timeoutlen = 300
o.confirm = true
o.synmaxcol = 300
o.shada = "'50,<50,s10,h"
o.statusline = " %f %m%r%=%y  %l:%c "

-- indentation
-- Indenting comes from Neovim's own per-language indent files (cindent for C and C++,
-- the python, javascript, typescript and systemverilog indent scripts, and so on).
-- smartindent is left off on purpose, it fights with those scripts.
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.autoindent = true
o.smartindent = false
o.breakindent = true
-- C and C++: match clang-format's default (LLVM) style, so typing and formatting agree
-- :0 case labels line up with switch, l1 case bodies indent from the label,
-- g0 public/private at class level, N-s no indent inside namespace,
-- E-s no indent inside extern "C", (0 continuation lines line up with the open paren
o.cinoptions = ":0,l1,g0,N-s,E-s,(0,W4"

if vim.g.remote then
  -- home directories on the server are usually network storage, so avoid extra writes
  o.swapfile = false
  o.backup = false
  o.writebackup = false
  o.undofile = false
  o.cursorline = false
  o.relativenumber = false
else
  o.undofile = true
  o.cursorline = true
  o.relativenumber = false -- plain line numbers; <space>ur turns relative numbers on and off
  vim.schedule(function()
    o.clipboard = "unnamedplus"
  end)
end
