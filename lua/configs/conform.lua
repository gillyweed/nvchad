local options = {
  formatters = {
    rubocop = {
      command = "rubocop-docker",
      args = { "$FILENAME" },
      stdin = false,
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    typescript = { "eslint_d" },
  },
}

return options
