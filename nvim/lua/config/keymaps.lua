-- General keymaps. Plugin keymaps live next to their plugin in lua/plugins/.
-- Press <space>sk inside Neovim to search every keymap.

local map = vim.keymap.set

map({ "n", "i" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map({ "n", "i" }, "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- keep the selection after indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- leave terminal mode with two escapes
map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Plugins" })
map("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Language servers" })
map("n", "<leader>U", function() require("config.update").all() end, { desc = "Update plugins, servers, parsers" })
