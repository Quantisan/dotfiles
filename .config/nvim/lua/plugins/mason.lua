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
}
