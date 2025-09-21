return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  {
    "snacks.nvim",
    opts = {
      notifier = {
        enabled = true,
        top_down = false, -- Change to false for bottom positioning
        margin = {
          top = 0,
          right = 1, -- Keeps notifications 1 cell away from the right edge
          bottom = 0, -- No bottom margin, so notifications appear at the bottom
        },
      },
      picker = {
        sources = {
          explorer = {
            layout = { layout = { position = "right" } },
            hidden = true,
          },
        },
      },
    },
  },
}
