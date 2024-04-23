require "nvchad.options"

-- add yours here!
vim.g.lua_snippets_path = vim.fn.stdpath "config" .. "/lua/snippets"

local o = vim.o

o.clipboard = "unnamed"
o.cursorlineopt = "both" -- to enable cursorline!

o.smartindent = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
