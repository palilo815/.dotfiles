-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "vscode_dark",

  -- hl_override = {
  -- 	Comment = { italic = true },
  -- 	["@comment"] = { italic = true },
  -- },

  term = {
    hl = "Normal:term,WinSeparator:WinSeparator",
    sizes = { sp = 0.3, vsp = 0.2 },
    float = {
      relative = "editor",
      row = 0.2,
      col = 0.1,
      width = 0.8,
      height = 0.6,
      border = "single",
    },
  },
}

return M
