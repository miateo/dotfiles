return {
	-- Ensure Mason installs Pyright and other tools
{
  "williamboman/mason.nvim",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      "pyright", -- LSP
      "black",   -- Formatter
      "isort",   -- Import sorter
      "flake8",  -- Linter
    })
  end,
},

	-- Set up LSP with Pyright
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				pyright = {},
			},
		},
	},

	-- Formatter: black & isort
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "isort", "black" },
			},
		},
	},
}
