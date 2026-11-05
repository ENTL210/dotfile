-- open the terminal in PowerShell 7 on Windows when it is installed, otherwise the default shell
local term_cmd = (vim.g.is_windows and vim.fn.executable("pwsh") == 1) and "pwsh" or nil

return {
  {
    "neanias/everforest-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("everforest").setup({
        background = "soft",
        transparent_background_level = 1,
        italics = true,
        on_highlights = function(hl)
          hl["@symbol"] = { link = "@field" }
        end,
      })
      vim.cmd.colorscheme("everforest")
    end,
  },

  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      picker = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } }, -- indent guide lines
      notifier = { enabled = true },
      terminal = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
    ███████╗██████╗ ████████╗███████╗██╗  ██╗
    ██╔════╝██╔══██╗╚══██╔══╝██╔════╝██║ ██╔╝
    █████╗  ██║  ██║   ██║   █████╗  █████╔╝
    ██╔══╝  ██║  ██║   ██║   ██╔══╝  ██╔═██╗
    ███████╗██████╔╝   ██║   ███████╗██║  ██╗
    ╚══════╝╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝
]],
          keys = {
            { key = "f", desc = "Find file", action = ":lua Snacks.picker.files()" },
            { key = "r", desc = "Recent files", action = ":lua Snacks.picker.recent()" },
            { key = "g", desc = "Search text", action = ":lua Snacks.picker.grep()" },
            { key = "e", desc = "File explorer", action = ":lua Snacks.explorer()" },
            { key = "c", desc = "Config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
            { key = "k", desc = "Keymaps", action = ":lua Snacks.picker.keymaps()" },
            { key = "u", desc = "Update plugins and servers", action = ":lua require('config.update').all()" },
            { key = "l", desc = "Plugins", action = ":Lazy" },
            { key = "m", desc = "Language servers", action = ":Mason" },
            { key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    keys = {
      { "<leader>e", function() Snacks.explorer() end, desc = "Explorer" },
      { "<leader><space>", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config files" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Search text" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Close buffer" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Search keymaps" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Search help" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics (all files)" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Symbols in file" },
      { "<leader>tt", function() Snacks.terminal(term_cmd) end, mode = { "n", "t" }, desc = "Toggle terminal" },
      { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Message history" },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 400,
      icons = { mappings = false },
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "toggle" },
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
        m("]h", function() gs.nav_hunk("next") end, "Next git change")
        m("[h", function() gs.nav_hunk("prev") end, "Previous git change")
        m("<leader>gp", gs.preview_hunk, "Preview change")
        m("<leader>gr", gs.reset_hunk, "Undo this change")
        m("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },
}
