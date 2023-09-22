-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- apply all *.lua snippet files in "snippets" directory
vim.g.lua_snippets_path = vim.fn.stdpath "config" .. "/lua/custom/snippets"
