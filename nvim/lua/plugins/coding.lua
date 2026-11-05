local remote = vim.g.remote

return {
  -- completion popup, fed by the language server, file paths, snippets and buffer words
  {
    "saghen/blink.cmp",
    version = "1.*", -- tagged releases have prebuilt binaries for Mac and Windows
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = {
        -- Enter accepts the highlighted item, Tab also accepts,
        -- C-n / C-p (or Up / Down) move, C-e closes the menu, C-space opens it
        preset = "enter",
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        -- accepting a function inserts "name()" with the cursor between the parentheses
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
      },
      signature = { enabled = true }, -- parameter hints show here while you type the arguments
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = {
        -- the Lua matcher avoids downloading a binary that may not run on the server
        implementation = remote and "lua" or "prefer_rust_with_warning",
        prebuilt_binaries = { download = not remote },
      },
    },
  },

  { "nvim-mini/mini.pairs", event = "InsertEnter", opts = {} },
}
