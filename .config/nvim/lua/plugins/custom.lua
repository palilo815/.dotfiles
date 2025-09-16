return {
  -- fix bug
  {
    "catppuccin/nvim",
    opts = function(_, opts)
      local module = require("catppuccin.groups.integrations.bufferline")
      if module then
        module.get = module.get_theme
      end
      return opts
    end,
  },

  -- use catppuccin colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- use floating terminal
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          position = "float",
        },
      },
    },
  },

  -- add tree-sitter-just
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "just",
      })
    end,
  },
}
