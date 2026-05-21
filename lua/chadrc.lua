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
    lazyload = false,
  },
  statusline = {
    modules = {
      file = function()
        local utils = require "nvchad.stl.utils"
        local stl_config = require("nvconfig").ui.statusline
        local sep_style = stl_config.separator_style
        local sep_icons = utils.separators
        local separators = (type(sep_style) == "table" and sep_style) or sep_icons[sep_style]
        local sep_r = separators["right"]

        local icon = "󰈚"
        local path = vim.api.nvim_buf_get_name(utils.stbufnr())
        local name

        if path == "" then
          name = "Empty"
        else
          name = vim.fn.fnamemodify(path, ":.")
          local filename = path:match "([^/\\]+)[/\\]*$"
          local ok, devicons = pcall(require, "nvim-web-devicons")
          if ok and filename then
            local ft_icon = devicons.get_icon(filename)
            icon = ft_icon or icon
          end
        end

        name = " " .. name .. (sep_style == "default" and " " or "")
        return "%#St_file# " .. icon .. name .. "%#St_file_sep#" .. sep_r
      end,
    },
  },
}


return M
