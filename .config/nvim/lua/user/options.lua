-- set vim options here (vim.<first_key>.<second_key> = value)
return {
  opt = {
    completeopt = { "menuone", "noselect" }, -- mostly just for cmp
    fileencoding = "UTF-8",
    mouse = "a", -- allow the mouse to be used in neovim
    pumheight = 10, -- pop up menu height
    showtabline = 0, -- never show tabs
    smartcase = true,
    smartindent = true,
    termguicolors = true,
    updatetime = 300, -- faster completion (4000ms default)
    cursorline = true,
    number = true,
    relativenumber = true,
    signcolumn = "yes", -- populates the signcolumn for you with something useful
    scrolloff = 8,
    sidescrolloff = 8,
    wrap = false, -- display lines as one long line

    -- Clipboard
    -- vim.opt.clipboard = "unnamedplus" -- access the system clipboard

    -- Create file
    backup = false,
    swapfile = false,
    undofile = true, -- enable persistent undo
    writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited

    -- Tab to spaces
    expandtab = true, -- convert tab to space
    shiftwidth = 4, -- number of spaces to use for each indentation
    tabstop = 4, -- 1 tab = 4 spaces

    -- Where to put the new window
    splitbelow = true,
    splitright = true,
  },
  g = {
    mapleader = " ", -- sets vim.g.mapleader
    autoformat_enabled = true, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    cmp_enabled = true, -- enable completion at start
    autopairs_enabled = true, -- enable autopairs at start
    diagnostics_mode = 3, -- set the visibility of diagnostics in the UI (0=off, 1=only show in status line, 2=virtual text off, 3=all on)
    icons_enabled = true, -- disable icons in the UI (disable if no nerd font is available, requires :PackerSync after changing)
    ui_notifications_enabled = true, -- disable notifications when toggling UI elements
  },
}
-- If you need more control, you can use the function()...end notation
-- return function(local_vim)
--   local_vim.opt.relativenumber = true
--   local_vim.g.mapleader = " "
--   local_vim.opt.whichwrap = vim.opt.whichwrap - { 'b', 's' } -- removing option from list
--   local_vim.opt.shortmess = vim.opt.shortmess + { I = true } -- add to option list
--
--   return local_vim
-- end

