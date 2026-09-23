-- Nothing in this config updates by itself. Run :Update (or press "u" on the
-- dashboard) when you want new plugin versions and new language server versions.

local function update_servers()
  -- make sure mason has been set up (it is loaded together with nvim-lspconfig)
  pcall(require("lazy").load, { plugins = { "nvim-lspconfig" } })
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

local M = {}

function M.all()
  update_servers()
  vim.cmd("Lazy update")
end

vim.api.nvim_create_user_command("Update", M.all, { desc = "Update plugins and language servers" })

return M
