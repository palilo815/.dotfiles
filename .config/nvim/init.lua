require('autocommand')  -- ~/.config/nvim/lua/autocommand.lua
require('config')       -- ~/.config/nvim/lua/config.lua
require('keybindings')  -- ~/.config/nvim/lua/keybindings.lua
require('packages')     -- ~/.config/nvim/lua/packages.lua
require('server')       -- ~/.config/nvim/lua/server.lua
require('snippet')      -- ~/.config/nvim/lua/snippet.lua

-- nightfox, nordfox, dayfox, dawnfox, duskfox.

-- Setup tree-sitter.
require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- Only use parsers that are maintained
    highlight = {
        enable = true,
    },
    indent = {
        enable = true, -- default is disabled anyways
    }
}

-- Setup nvim-cmp.
local cmp = require'cmp'
cmp.setup {
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
    }, {
        { name = 'buffer' },
    })
}

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})
