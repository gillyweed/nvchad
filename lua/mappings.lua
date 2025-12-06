require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "H", "0", { desc = "Jump to line start"})
map("n", "L", "$", { desc = "Jump to line end"})

map("n","<Esc>", "<cmd>nohlsearch<CR>", {desc = "Clear highlights on search when pressing <Esc>"})
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

map("t","<C-x>","<C-\\><C-n>", {desc = "Exit terminal mode"})

-- keep cursor in the middle of the screen when jumping
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nvvvv')

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
