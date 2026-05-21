require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

-- replace <C-n> nvim-tree toggle with <leader>n
map("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle nvimtree" })

-- toggle focus between nvimtree and the buffer
map("n", "<leader>e", function()
  local nvimtree = require("nvim-tree.api")
  local current_buf = vim.api.nvim_get_current_buf()
  if vim.bo[current_buf].filetype == "NvimTree" then
    vim.cmd("wincmd p")
  else
    nvimtree.tree.focus()
  end
end, { desc = "Toggle focus between nvimtree and buffer" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "H", "^", { desc = "Jump to line start" })
map("n", "L", "$", { desc = "Jump to line end" })
map("o", "H", "^")
map("o", "L", "$")


map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights on search when pressing <Esc>" })
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

map("t", "<C-x>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- d and c deletes to the blackhole register
map("n", "d", '"_d')
map("v", "d", '"_d')
map("n", "c", '"_c')
map("v", "c", '"_c')

-- x as cut (sends to main register)
map("n", "x", '"+d')
map("v", "x", '"+d')

-- xx to cut a whole line
map("n", "xx", '"+dd')

-- X to cut from cursor to end of line
map("n", "X", '"+D')

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- keep cursor in the middle of the screen when jumping
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nvvvv')

-- Resize splits
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Resize split up" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Resize split down" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize split left" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize split right" })

map("n", "<leader>x", function()
  -- Close the current buffer
  require("nvchad.tabufline").close_buffer()

  -- Check if only nvim-tree and/or empty buffers remain
  vim.defer_fn(function()
    -- Don't quit if multiple tabs
    if #vim.api.nvim_list_tabpages() > 1 then
      return
    end

    local wins = vim.api.nvim_list_wins()
    local has_real_buffer = false

    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bufname = vim.api.nvim_buf_get_name(buf)

      -- Skip nvim-tree and empty unnamed buffers
      if ft ~= "NvimTree" and (bufname ~= "" or vim.bo[buf].modified) then
        has_real_buffer = true
        break
      end
    end

    -- Quit if no real buffers remain (only nvim-tree and/or empty buffers)
    if not has_real_buffer then
      vim.cmd("quit")
    end
  end, 50)
end, { desc = "Close buffer and quit if last" })
