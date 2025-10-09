return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  {
    "snacks.nvim",
    keys = {
      -- Override default keymaps to switch behavior
      {
        "<leader>e",
        function()
          Snacks.explorer({ cwd = vim.fn.getcwd() })
        end,
        desc = "Explorer Snacks (cwd)",
      },
      {
        "<leader>E",
        function()
          Snacks.explorer({ cwd = LazyVim.root() })
        end,
        desc = "Explorer Snacks (Root Dir)",
      },
    },
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
