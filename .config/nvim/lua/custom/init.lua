-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- apply all *.lua snippet files in "snippets" directory
vim.g.lua_snippets_path = vim.fn.stdpath("config") .. "/lua/custom/snippets"

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.clipboard = "unnamed"

if vim.g.neovide then
	require("custom.configs.neovide")
end
