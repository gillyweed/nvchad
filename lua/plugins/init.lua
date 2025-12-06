local function open_nvim_tree(data)
  local directory = vim.fn.isdirectory(data.file) == 1
  if not directory or #vim.api.nvim_list_bufs() > 1 then
    return
  end
  require("nvim-tree.api").tree.toggle(false, true)
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

return {

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = function()
      return require "configs.nvimtree"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "L3MON4D3/LuaSnip",
    build = (function()
      if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
        return
      end
      return "make install_jsregexp"
    end)(),
    dependencies = { "rafamadriz/friendly-snippets" },
  },

  {
  	"nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
        "html", "css", "javascript",
        "typescript", "bash", "markdown",
        "json", "yaml", "xml"
  		},

      highlight = {
        enable = true,
        use_languagetree = true,
      },

      indent = {
        enable = true,
      },
  	},
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
