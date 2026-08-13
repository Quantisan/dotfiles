local notifications = {}
local scheduled = {}
local registry_updates = 0
local registry_inspections = 0
local registry_success = true
local packages = {}

package.preload["lazy"] = function()
  return {
    load = function() end,
  }
end

package.preload["mason-registry"] = function()
  return {
    update = function(callback)
      registry_updates = registry_updates + 1
      callback(registry_success)
    end,
    get_installed_packages = function()
      registry_inspections = registry_inspections + 1
      return packages
    end,
  }
end

vim.schedule = function(callback)
  table.insert(scheduled, callback)
end

vim.notify = function(message, level)
  table.insert(notifications, { message = message, level = level })
end

local function reset(options)
  options = options or {}
  notifications = {}
  scheduled = {}
  registry_updates = 0
  registry_inspections = 0
  registry_success = options.registry_success ~= false
  packages = options.packages or {}
end

local function make_package(options)
  local installs = 0
  return {
    name = options.name,
    get_installed_version = function()
      return options.installed
    end,
    get_latest_version = function()
      if options.latest_error then
        error(options.latest_error)
      end
      return options.latest
    end,
    is_installing = function()
      return options.is_installing or false
    end,
    install = function()
      installs = installs + 1
    end,
    install_count = function()
      return installs
    end,
  }
end

local function trigger(pattern)
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

local function drain_scheduled()
  while #scheduled > 0 do
    table.remove(scheduled, 1)()
  end
end

local function assert_equal(actual, expected, context)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", context, vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

local function assert_notification(index, message, level)
  local notification = notifications[index]
  if not notification then
    error(string.format("notification %d: expected %s, got none", index, vim.inspect(message)), 2)
  end
  assert_equal(notification.message, message, string.format("notification %d message", index))
  if level ~= nil then
    assert_equal(notification.level, level, string.format("notification %d level", index))
  end
end

local tests = {}

local function test(name, callback)
  table.insert(tests, { name = name, callback = callback })
end

-- The source file is the system under test; only its external plugins and async
-- scheduler are replaced so the registered autocmd and callback run unchanged.
dofile(".config/nvim/lua/config/autocmds.lua")

test("LazyUpdate runs once and LazySync does not run", function()
  reset()

  trigger("LazyUpdate")
  drain_scheduled()
  assert_equal(registry_updates, 1, "registry updates after LazyUpdate")

  trigger("LazySync")
  drain_scheduled()
  assert_equal(registry_updates, 1, "registry updates after LazySync")
end)

test("upgradeable packages install with one informational notification", function()
  local lua_ls = make_package({ name = "lua-language-server", installed = "1.0.0", latest = "2.0.0" })
  local stylua = make_package({ name = "stylua", installed = "1.0.0", latest = "1.1.0" })
  reset({ packages = { lua_ls, stylua } })

  trigger("LazyUpdate")
  drain_scheduled()

  assert_equal(lua_ls.install_count(), 1, "lua-language-server installs")
  assert_equal(stylua.install_count(), 1, "stylua installs")
  assert_equal(#notifications, 1, "notification count")
  assert_notification(1, "Mason: upgrading lua-language-server, stylua", vim.log.levels.INFO)
end)

test("an outdated package already installing is still reported as upgrading", function()
  local installing = make_package({
    name = "installing",
    installed = "1.0.0",
    latest = "2.0.0",
    is_installing = true,
  })
  reset({ packages = { installing } })

  trigger("LazyUpdate")
  drain_scheduled()

  assert_equal(installing.install_count(), 0, "duplicate installs")
  assert_equal(#notifications, 1, "notification count")
  assert_notification(1, "Mason: upgrading installing", vim.log.levels.INFO)
end)

test("uncheckable packages produce one warning with their names", function()
  local missing = make_package({ name = "missing-receipt", installed = nil, latest = "2.0.0" })
  local malformed = make_package({
    name = "malformed-source",
    installed = "1.0.0",
    latest_error = "malformed source id",
  })
  reset({ packages = { missing, malformed } })

  trigger("LazyUpdate")
  drain_scheduled()

  assert_equal(#notifications, 1, "notification count")
  assert_notification(1, "Mason: unable to check missing-receipt, malformed-source", vim.log.levels.WARN)
end)

test("mixed results produce at most one upgrade and one unchecked notification", function()
  local current = make_package({ name = "current", installed = "1.0.0", latest = "1.0.0" })
  local upgrade = make_package({ name = "upgrade", installed = "1.0.0", latest = "2.0.0" })
  local unchecked = make_package({ name = "unchecked", installed = nil, latest = "2.0.0" })
  reset({ packages = { current, upgrade, unchecked } })

  trigger("LazyUpdate")
  drain_scheduled()

  assert_equal(upgrade.install_count(), 1, "upgrade installs")
  assert_equal(#notifications, 2, "notification count")
  assert_notification(1, "Mason: upgrading upgrade", vim.log.levels.INFO)
  assert_notification(2, "Mason: unable to check unchecked", vim.log.levels.WARN)
end)

test("all-current notification appears only when both result lists are empty", function()
  local current = make_package({ name = "current", installed = "1.0.0", latest = "1.0.0" })
  reset({ packages = { current } })

  trigger("LazyUpdate")
  drain_scheduled()

  assert_equal(#notifications, 1, "notification count")
  assert_notification(1, "Mason: all tools up to date")
end)

test("registry update failure warns and skips package inspection", function()
  local package = make_package({ name = "unchecked", installed = nil, latest = "2.0.0" })
  reset({ registry_success = false, packages = { package } })

  trigger("LazyUpdate")
  drain_scheduled()

  assert_equal(registry_inspections, 0, "registry inspections")
  assert_equal(#notifications, 1, "notification count")
  assert_notification(1, "Mason: registry update failed", vim.log.levels.WARN)
end)

local failures = {}
for _, case in ipairs(tests) do
  local ok, message = pcall(case.callback)
  if not ok then
    table.insert(failures, string.format("- %s\n  %s", case.name, message))
  end
end

if #failures > 0 then
  error(string.format("%d Mason notification regression test(s) failed:\n%s", #failures, table.concat(failures, "\n")))
end

print(string.format("Mason update notifications: %d tests passed", #tests))
