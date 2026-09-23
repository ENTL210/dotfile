local remote = vim.g.remote

-- language servers: clangd (c, c++), pyright (python), ts_ls (typescript, javascript)
-- pyright and ts_ls are installed through npm, so node must be available on the machine
local servers = { "clangd", "pyright", "ts_ls" }

return {
  -- completion popup, fed by the language server, file paths, snippets and buffer words
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "super-tab" }, -- Tab accepts, C-n / C-p move
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = {
        -- the Lua matcher avoids downloading a binary that may not run on the server
        implementation = remote and "lua" or "prefer_rust_with_warning",
        prebuilt_binaries = { download = not remote },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "bash", "c", "cpp", "javascript", "json", "lua", "markdown", "markdown_inline",
        "python", "query", "tsx", "typescript", "vim", "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  { "nvim-mini/mini.pairs", event = "InsertEnter", opts = {} },

  -- language servers, needs Neovim 0.11 or newer
  {
    "neovim/nvim-lspconfig",
    enabled = vim.fn.has("nvim-0.11") == 1,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim", "saghen/blink.cmp" },
    config = function()
      vim.diagnostic.config({ severity_sort = true, virtual_text = { spacing = 2 } })

      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function o(desc) return { buffer = ev.buf, desc = desc } end
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, o("Go to definition"))
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o("Go to declaration"))
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, o("Go to type definition"))
          vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, o("Format"))
          vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, o("Line diagnostics"))
        end,
      })

      -- registry_cache.refresh = false stops mason from refreshing its package list on its own
      require("mason").setup({ registry_cache = { refresh = false } })

      local function install_servers()
        require("mason-lspconfig").setup({ ensure_installed = servers, automatic_enable = false })
      end
      local registry = require("mason-registry")
      if registry.sources:is_all_installed() then
        install_servers()
      else
        -- first run only: fetch the package list once so the servers can be installed
        registry.update(vim.schedule_wrap(install_servers))
      end

      vim.lsp.enable(servers)
    end,
  },
}
