-- Language servers, installed by Mason the first time Neovim opens a file.
--   clangd    C, C++
--   pyright   Python (types, go to definition)       needs node
--   ruff      Python (lint, format, organize imports)
--   ts_ls     JavaScript, TypeScript                  needs node
--   verible   SystemVerilog, Verilog (lint, format)
--   texlab    LaTeX completion and diagnostics
--   lua_ls    Lua (for editing this config)

local servers = { "clangd", "ruff", "verible", "texlab", "lua_ls" }
if vim.fn.executable("npm") == 1 then
  -- these two are installed through npm, so only ask for them where node exists
  vim.list_extend(servers, { "pyright", "ts_ls" })
end

local function setup_servers()
  vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

  vim.lsp.config("clangd", {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=never",
      "--completion-style=detailed",
      -- complete functions as name() with the cursor inside, no (char c, int n) placeholders
      "--function-arg-placeholders=0",
    },
  })

  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim", "Snacks" } },
        workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        telemetry = { enable = false },
      },
    },
  })

  vim.diagnostic.config({
    severity_sort = true,
    virtual_text = { spacing = 2 },
    float = { border = "rounded", source = true },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      -- pyright gives better hover text than ruff
      if client and client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end

      local function m(lhs, rhs, desc, mode)
        vim.keymap.set(mode or "n", lhs, rhs, { buffer = ev.buf, desc = desc })
      end
      m("gd", function() Snacks.picker.lsp_definitions() end, "Go to definition")
      m("gD", vim.lsp.buf.declaration, "Go to declaration")
      m("gy", function() Snacks.picker.lsp_type_definitions() end, "Go to type definition")
      m("grr", function() Snacks.picker.lsp_references() end, "References")
      m("gri", function() Snacks.picker.lsp_implementations() end, "Implementations")
      m("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
      m("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
      m("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format file")
      m("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
      m("<leader>ch", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
      end, "Toggle inlay hints")
      if client and client.name == "clangd" then
        m("<leader>co", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch .c/.h file")
      end
    end,
  })
end

return {
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "Mason", "LspInstall" },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig", -- supplies the default settings for every server
      "saghen/blink.cmp",
    },
    config = function()
      setup_servers()
      -- installs anything missing, then turns on every server Mason has installed
      -- (including ones you add later from :Mason), so no restart is needed after the first install
      require("mason-lspconfig").setup({ ensure_installed = servers, automatic_enable = true })
    end,
  },
}
