require('packer').startup(function()
    -- themes
    use 'savq/melange'
    use 'marko-cerovac/material.nvim'
    use 'sainnhe/sonokai'
    use 'arcticicestudio/nord-vim'
    use 'EdenEast/nightfox.nvim'
    use 'shaunsingh/solarized.nvim'

    -- tree-sitter
    use 'nvim-treesitter/nvim-treesitter'

    -- lsp
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'

    -- nvim-cmp
    use({
        'hrsh7th/nvim-cmp', -- auto completion
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-cmdline',
            'windwp/nvim-autopairs',
        },
    })

    -- coc.nvim
    use {'neoclide/coc.nvim', branch = 'release'}

    use('ray-x/lsp_signature.nvim')

    use('lewis6991/impatient.nvim')     -- speedup lua module load time
    use('nathom/filetype.nvim')         -- replaces filetype load from vim for a more performant one

    use('simrat39/rust-tools.nvim')     -- rust support enhancements

    -- use('jiangmiao/auto-pairs')
    use('LunarWatcher/auto-pairs')
    -- use('cohama/lexima.vim')
    -- use('windwp/nvim-autopairs')
end)

