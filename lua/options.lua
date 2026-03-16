require "nvchad.options"

local o = vim.o
o.cursorlineopt ='both'

o.relativenumber = true
vim.opt_global.fileformat = "unix"

o.cursorline = true
o.scrolloff = 10

vim.g.clipboard = {
  name = "WSLgClipboard",
  copy = {
    ["+"] = { "wl-copy", "--type", "text/plain" },
    ["*"] = { "wl-copy", "--type", "text/plain" },
  },
  paste = {
    ["+"] = { "sh", "-c", "wl-paste --no-newline | tr -d '\r'"},
    ["*"] = { "sh", "-c", "wl-paste --no-newline | tr -d '\r'"},
  },
  cache_enabled = 0,
}
