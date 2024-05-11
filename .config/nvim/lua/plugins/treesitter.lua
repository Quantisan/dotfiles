return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = { enable = false },
      ensure_installed = {
        "clojure",
        "python",
        "hcl",
      },
    },
  },
}
