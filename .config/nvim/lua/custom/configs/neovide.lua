vim.o.guifont = "MesloLGS NF:h16"
vim.g.neovide_cursor_vfx_mode = "railgun"

vim.keymap.set("v", "<C-C>", '"+y') -- Copy
vim.keymap.set("n", "<C-V>", '"+P') -- Paste normal mode
vim.keymap.set("v", "<C-V>", '"+P') -- Paste visual mode
vim.keymap.set("c", "<C-V>", "<C-R>+") -- Paste command mode
vim.keymap.set("i", "<C-V>", '<ESC>l"+Pli') -- Paste insert mode

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<C-V>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<C-V>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-V>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-V>", "<C-R>+", { noremap = true, silent = true })
