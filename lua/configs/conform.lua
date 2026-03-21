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

  format_after_save = function(bufnr)
    if vim.bo[bufnr].filetype == "ruby" then
      return { timeout_ms = 10000, lsp_fallback = true }
    end
    return { timeout_ms = 5000, lsp_fallback = true }
  end,
}

return options
