require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("html", {
  filetypes = { "html", "eruby" },
})

local servers = { "html", "cssls", "ts_ls" }
vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ruby",
  callback = function(args)
    local fname = vim.api.nvim_buf_get_name(args.buf)
    local root = vim.fs.dirname(
      vim.fs.find({ "Gemfile", ".git" }, { path = fname, upward = true })[1]
    ) or vim.fn.getcwd()
    vim.lsp.start({
      name = "ruby_lsp",
      cmd = { "/home/gillom/.local/bin/ruby-lsp-docker" },
      root_dir = root,
    })
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    severity = { min = vim.diagnostic.severity.HINT },
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "»",
    },
  },
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
})
