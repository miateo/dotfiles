return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Open and read the content of the text file
		local file = io.open("/home/ace/.config/nvim/lua/dash_arts/archangel.txt", "r")
		local content = file:read("*a")
		file:close()

		-- Assign the value to the variable
		dashboard.section.header.val = content

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  ⇨ New File", "<cmd>ene<CR>"),
			dashboard.button("SPC ee", "  ⇨ Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
			dashboard.button("SPC ff", "󰱼  ⇨ Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC fs", "  ⇨ Find Word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("SPC wr", "󰁯  ⇨ Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
			dashboard.button("q", "  ⇨ Quit NVIM", "<cmd>qa<CR>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
