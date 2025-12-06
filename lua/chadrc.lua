-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "gruvbox",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.nvdash = { load_on_startup = true }
M.ui = {
      tabufline = {
         lazyload = false
     }
}

M.plugins = {
  ["nvim-tree/nvim-tree.lua"] = {
    lazy = false,
    config = function()
      require("nvim-tree").setup {
        git = {
          timeout = 1000,
        },
      }
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          local tree_wins = {}
          local other_wins = {}

          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "NvimTree" then
              table.insert(tree_wins, win)
            else
              table.insert(other_wins, win)
            end
          end

          -- If closing last non-tree window, close tree too
          if #other_wins == 1 and #tree_wins > 0 then
            vim.cmd("NvimTreeClose")
          end
        end,
      })

    end,
  },
}
return M
