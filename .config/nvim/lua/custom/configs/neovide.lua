vim.o.guifont = "MesloLGS NF:h16"
vim.g.neovide_cursor_vfx_mode = "railgun"

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<C-V>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<C-V>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-V>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-V>", "<C-R>+", { noremap = true, silent = true })
