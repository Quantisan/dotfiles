-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Disable autoformat for clojure files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "clojure" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Upgrade installed Mason tools whenever lazy.nvim finishes updating plugins, so
-- `:Lazy update` also covers language servers, linters and formatters.
vim.api.nvim_create_autocmd("User", {
  pattern = { "LazyUpdate", "LazySync" },
  callback = function()
    require("lazy").load({ plugins = { "mason.nvim" } })
    local mr = require("mason-registry")
    mr.update(function(success)
      if not success then
        vim.schedule(function()
          vim.notify("Mason: registry update failed", vim.log.levels.WARN)
        end)
        return
      end
      local upgrading = {}
      for _, pkg in ipairs(mr.get_installed_packages()) do
        local installed = pkg:get_installed_version()
        -- get_latest_version throws when a package has a malformed source id
        local ok, latest = pcall(pkg.get_latest_version, pkg)
        if ok and installed and installed ~= latest and not pkg:is_installing() then
          pkg:install()
          table.insert(upgrading, pkg.name)
        end
      end
      -- vim.notify runs UI code, so defer it out of mason's async runner
      vim.schedule(function()
        vim.notify(
          #upgrading > 0 and ("Mason: upgrading " .. table.concat(upgrading, ", ")) or "Mason: all tools up to date"
        )
      end)
    end)
  end,
})
