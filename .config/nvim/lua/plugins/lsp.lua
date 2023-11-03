return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Clojure
        "clj-kondo",
        "clojure-lsp",
        "joker",

        -- Python
        "flake8",
        "black",
        "isort",
        "ruff",
        "mypy",
        "python-lsp-server",

        -- Terraform
        "terraform-ls",
        "tflint",

        -- Javascript
        "rome",

        -- Lua
        "lua-language-server",
        "stylua",

        -- Others
        "json-lsp",
        "shfmt",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          mason = false,
          autostart = false,
        },
      },
    },
  },
}
