-- Nothing in this config updates by itself. Run :Update (or press "u" on the
-- dashboard, or <space>U) when you want new plugin, language server and
-- treesitter parser versions.

local function update_servers()
  -- make sure mason has been set up (it is loaded together with the LSP plugins)
  pcall(require("lazy").load, { plugins = { "mason-lspconfig.nvim" } })
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end

  vim.notify("Checking language server versions...")
  registry.update(vim.schedule_wrap(function(success, result)
    if not success then
      local reason = type(result) == "table" and table.concat(vim.tbl_map(tostring, result), "; ") or tostring(result)
      vim.notify("Mason registry update failed: " .. reason, vim.log.levels.ERROR)
      return
    end
    local count = 0
    for _, pkg in ipairs(registry.get_installed_packages()) do
      local checked, outdated = pcall(function()
        return pkg:get_installed_version() ~= pkg:get_latest_version()
      end)
      if checked and outdated and not pkg:is_installing() then
        count = count + 1
        pkg:install()
      end
    end
    if count == 0 then
      vim.notify("Language servers are up to date")
    else
      vim.notify(("Updating %d language server(s), progress is shown in :Mason"):format(count))
    end
  end))
end

local function update_parsers()
  if vim.fn.exists(":TSUpdate") == 2 and vim.fn.executable("tree-sitter") == 1 then
    vim.cmd("TSUpdate")
  end
end

local M = {}

function M.all()
  update_servers()
  update_parsers()
  vim.cmd("Lazy update")
end

vim.api.nvim_create_user_command("Update", M.all, { desc = "Update plugins, language servers and parsers" })

return M
