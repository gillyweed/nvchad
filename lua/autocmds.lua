require "nvchad.autocmds"

-- Automatically enter insert mode when switching to a terminal window
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "term://*",
  command = "startinsert",
})
