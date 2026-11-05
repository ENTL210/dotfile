-- Treesitter is used for syntax highlighting only. Indenting is left to Neovim's
-- own indent scripts, which are more reliable (treesitter indent was the cause of
-- the broken C indents).
--
-- Building parsers needs the tree-sitter CLI (0.26.1+) and a C compiler:
--   Mac:     brew install tree-sitter-cli   (compiler comes with Xcode command line tools)
--   Windows: see README.md
-- Without the CLI nothing breaks: Neovim keeps its bundled parsers (c, lua, markdown,
-- vim, vimdoc, query) and every other language falls back to regular syntax colors.

local parsers = {
  "bash", "c", "cpp", "javascript", "typescript", "tsx", "json", "lua", "markdown",
  "markdown_inline", "python", "query", "systemverilog", "vim", "vimdoc",
}

-- vimtex does its own LaTeX highlighting, treesitter would conflict with it
local skip = { tex = true, latex = true, plaintex = true, bib = true }

-- only try to build parsers when both the CLI and some C compiler exist,
-- otherwise every startup would retry and print errors
local function can_build()
  if vim.fn.executable("tree-sitter") == 0 then
    return false
  end
  for _, cc in ipairs({ "cc", "gcc", "clang", "cl", "zig" }) do
    if vim.fn.executable(cc) == 1 then
      return true
    end
  end
  -- on Windows the tree-sitter CLI finds Visual Studio Build Tools by itself, even off PATH
  if vim.g.is_windows then
    local pf = os.getenv("ProgramFiles(x86)") or "C:\\Program Files (x86)"
    return vim.fn.filereadable(pf .. "\\Microsoft Visual Studio\\Installer\\vswhere.exe") == 1
  end
  return false
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- this plugin does not support lazy loading
    build = function()
      if can_build() then
        vim.cmd("TSUpdate")
      end
    end,
    config = function()
      if can_build() then
        -- runs in the background, already installed parsers are skipped
        require("nvim-treesitter").install(parsers)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          if skip[ev.match] then
            return
          end
          -- quietly does nothing when there is no parser for this language
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },
}
