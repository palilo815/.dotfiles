local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

	-- Override plugin definition options

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- format & linting
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("custom.configs.null-ls")
				end,
			},
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end, -- Override to setup mason-lspconfig
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			-- sorry CPU, just burn for the first time...
			ensure_installed = "all",
		},
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = {
			-- the default setting is true, so I cannot see the ignored files in tree
			git = {
				ignore = false,
			},
		},
	},

	-- Install a plugin
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},

	{
		"simrat39/rust-tools.nvim",
		-- language tools must be loaded after lspconfig
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		-- just apply default setup
		config = function()
			require("rust-tools").setup()
		end,
		ft = "rust",
	},
	{
		"p00f/clangd_extensions.nvim",
		-- language tools must be loaded after lspconfig
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		-- just apply default setup
		config = function()
			require("clangd_extensions").setup()
		end,
		ft = "cpp",
	},
	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },

	-- All NvChad plugins are lazy-loaded by default
	-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
	-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
	-- {
	--   "mg979/vim-visual-multi",
	--   lazy = false,
	-- }
}

return plugins
