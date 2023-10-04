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
        "pyright",

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
    "nvimtools/none-ls.nvim",
    opts = function()
      local nls = require("null-ls")
      return {
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {
          nls.builtins.diagnostics.mypy,
          nls.builtins.formatting.isort,
          nls.builtins.formatting.black,
          nls.builtins.formatting.ruff,
        },
      }
    end,
  },
}
