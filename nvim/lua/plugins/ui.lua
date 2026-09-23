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
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Search text" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Close buffer" },
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
      },
    },
  },
}
