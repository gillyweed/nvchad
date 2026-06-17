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

-- show git blame for the current line in a readable popup (author, relative
-- time + date, and commit summary -- no hash)
local function relative_time(t)
  local diff = os.difftime(os.time(), t)
  local units = {
    { 31536000, "year" },
    { 2592000, "month" },
    { 604800, "week" },
    { 86400, "day" },
    { 3600, "hour" },
    { 60, "minute" },
  }
  for _, u in ipairs(units) do
    if diff >= u[1] then
      local n = math.floor(diff / u[1])
      return n .. " " .. u[2] .. (n > 1 and "s" or "") .. " ago"
    end
  end
  return "just now"
end

-- from a unified diff, find the hunk whose new-side range covers `target`
local function find_hunk(diff, target)
  if not target then
    return nil
  end
  local hunks, cur = {}, nil
  for _, l in ipairs(diff) do
    local ns, nc = l:match "^@@ %-%d+,?%d* %+(%d+),?(%d*) @@"
    if ns then
      ns = tonumber(ns)
      nc = nc ~= "" and tonumber(nc) or 1
      cur = { lo = ns, hi = ns + math.max(nc, 1) - 1, body = {} }
      hunks[#hunks + 1] = cur
    elseif cur then
      local c = l:sub(1, 1)
      if c == " " or c == "+" or c == "-" then
        cur.body[#cur.body + 1] = l
      end
    end
  end
  for _, h in ipairs(hunks) do
    if target >= h.lo and target <= h.hi then
      return h
    end
  end
  return nil
end

-- keep only the diff body lines within `ctx` new-file lines of `target`
local function trim_around(hunk, target, ctx)
  local out, newln = {}, hunk.lo
  for _, l in ipairs(hunk.body) do
    if newln >= target - ctx and newln <= target + ctx then
      out[#out + 1] = l
    end
    if l:sub(1, 1) ~= "-" then -- '-' lines don't exist on the new side
      newln = newln + 1
    end
  end
  return out
end

-- open a focused, scrollable float; <Esc> or q closes it
local function open_blame_float(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "diff"
  vim.bo[buf].modifiable = false

  local width, height = 0, #lines
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = math.min(width + 1, vim.o.columns - 4),
    height = math.min(height, vim.o.lines - 6),
    border = "rounded",
    style = "minimal",
  })
  vim.wo[win].wrap = false
  for _, key in ipairs { "<Esc>", "q" } do
    map("n", key, "<cmd>close<CR>", { buffer = buf, nowait = true })
  end
end

map("n", "<leader>gb", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return
  end
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local dir = vim.fn.fnamemodify(file, ":h")
  local out = vim.fn.systemlist {
    "git", "-C", dir, "blame", "-L", lnum .. "," .. lnum,
    "--line-porcelain", "--", file,
  }
  if vim.v.shell_error ~= 0 then
    vim.notify("git blame failed", vim.log.levels.WARN)
    return
  end

  local sha, orig = out[1]:match "^(%x+)%s+(%d+)"
  orig = tonumber(orig)
  if sha and sha:match "^0+$" then
    open_blame_float { "Not committed yet" }
    return
  end

  local info = {}
  for _, line in ipairs(out) do
    if line:sub(1, 1) == "\t" then
      break
    end
    local key, val = line:match "^([%w%-]+) (.*)$"
    if key == "author" then
      info.author = val
    elseif key == "author-time" then
      info.time = tonumber(val)
    elseif key == "summary" then
      info.summary = val
    end
  end

  local header = info.author or "Unknown"
  if info.time then
    header = header .. " • " .. relative_time(info.time) .. " (" .. os.date("%Y-%m-%d", info.time) .. ")"
  end

  local lines = { header, "", info.summary or "" }
  local diff = vim.fn.systemlist {
    "git", "-C", dir, "show", "--format=", "--no-color", sha, "--", file,
  }
  if vim.v.shell_error == 0 and #diff > 0 then
    local hunk = find_hunk(diff, orig)
    local body = hunk and trim_around(hunk, orig, 3) or diff
    table.insert(lines, "")
    vim.list_extend(lines, body)
  end
  open_blame_float(lines)
end, { desc = "Git blame (popup)" })

-- jump to the next/previous git hunk (unstaged change) in the current buffer
map("n", "<leader>fg", function()
  require("gitsigns").nav_hunk("next")
end, { desc = "Find next git hunk" })

map("n", "<leader>Fg", function()
  require("gitsigns").nav_hunk("prev")
end, { desc = "Find previous git hunk" })

-- preview the diff of the hunk under the cursor (old vs new lines) inline
map("n", "<leader>gd", function()
  require("gitsigns").preview_hunk()
end, { desc = "Git diff hunk (preview)" })

-- fuzzy, previewable LSP navigation via Telescope
map("n", "<leader>fr", "<cmd>Telescope lsp_references<CR>", { desc = "Find LSP references" })
map("n", "<leader>fd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Find LSP definitions" })

-- manually format the current buffer / selection (conform, falling back to LSP)
map({ "n", "v" }, "<leader>mp", function()
  require("conform").format { lsp_fallback = true, timeout_ms = 10000 }
end, { desc = "Format buffer" })

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
