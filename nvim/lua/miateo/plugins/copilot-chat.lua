return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- required for Copilot auth
			{ "nvim-lua/plenary.nvim" }, -- required helper lib
		},
		config = function()
			require("CopilotChat").setup({
				window = {
					layout = "float", -- or "vertical" if you prefer
					width = 0.4,
					height = 0.5,
				},
			})
		end,
	},
}
