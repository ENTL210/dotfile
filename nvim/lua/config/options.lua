vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- true when connected over ssh (the OSU server); used to trim features below
vim.g.remote = vim.env.SSH_CONNECTION ~= nil

-- skip provider setup, it costs startup time and nothing here needs it
for _, p in ipairs({ "python3", "node", "ruby", "perl" }) do
  vim.g["loaded_" .. p .. "_provider"] = 0
end

local o = vim.opt
o.number = true
o.mouse = "a"
o.signcolumn = "yes"
o.termguicolors = true
o.splitright = true
o.splitbelow = true
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = false
o.scrolloff = 6
o.updatetime = 250
o.timeoutlen = 300
o.confirm = true
o.synmaxcol = 300
o.shada = "'50,<50,s10,h"
o.statusline = " %f %m%r%=%y  %l:%c "

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
  o.relativenumber = true
  vim.schedule(function()
    o.clipboard = "unnamedplus"
  end)
end
