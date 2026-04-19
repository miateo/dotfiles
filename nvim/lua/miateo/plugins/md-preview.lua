return {
	"iamcco/markdown-preview.nvim",
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Launch markdown preview" },
	},
	ft = { "markdown" },
	cmd = { "MarkdownPreview" },
}
