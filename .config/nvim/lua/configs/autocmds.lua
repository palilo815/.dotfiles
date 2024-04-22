-- remember cursor position
vim.cmd [[
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]]

-- automatically saves & loads folds when closing or opening a file
-- vim.opt.viewoptions-=options
vim.cmd [[
    autocmd!
    autocmd BufWinLeave *.* mkview
    autocmd BufWinEnter *.* silent! loadview
]]
