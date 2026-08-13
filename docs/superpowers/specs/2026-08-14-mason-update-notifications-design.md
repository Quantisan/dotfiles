# Mason Update Notifications Design

## Goal

Keep installed Mason tools current whenever lazy.nvim completes an update, without running the update workflow twice or claiming that unchecked packages are current.

## Behavior

- Listen only for the `LazyUpdate` user event. lazy.nvim emits this event during both `:Lazy update` and the update phase of `:Lazy sync`, so a separate `LazySync` pattern is redundant.
- Refresh the Mason registry and inspect every installed package as before.
- Add packages with a known installed version and a newer registry version to an `upgrading` list, then start their installation.
- Add packages to an `unchecked` list when their installed version is missing or `get_latest_version` raises an error.
- Emit at most two scheduled notifications after inspection:
  - An informational `Mason: upgrading <names>` message when `upgrading` is non-empty.
  - A warning-level `Mason: unable to check <names>` message when `unchecked` is non-empty.
- Emit `Mason: all tools up to date` only when both lists are empty.

## Error Handling

A failed registry update continues to emit the existing warning and stops package inspection. Per-package version errors remain isolated so one malformed package cannot abort the remaining checks, but affected package names are surfaced instead of being silently treated as current.

## Verification

Use a headless Neovim regression harness with stubbed lazy.nvim and Mason modules to verify that:

1. `LazyUpdate` invokes the registry workflow once and `LazySync` does not invoke it.
2. Upgradeable packages produce one informational notification.
3. Missing installed versions and malformed source versions produce one warning containing their names.
4. Mixed results produce at most one informational and one warning notification.
5. The all-current message appears only when no packages are upgrading or unchecked.

Run the repository's available Lua formatting and whitespace checks after the regression harness passes.
