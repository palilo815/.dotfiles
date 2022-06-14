require "user.options"
require "user.keymaps"
require "user.plugins"
require "user.colorscheme"
require "user.cmp"
require "user.snippet"
require "user.lsp"
require "user.treesitter"
require "user.autopairs"
-- require "user.language.cpp"

require("clangd_extensions").setup()
require('rust-tools').setup({})

