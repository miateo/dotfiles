vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap -- for concisensess

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Terminal keymap to exit insert mode with Esc
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		-- Map 'Esc' in terminal mode to exit terminal insert mode
		vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
	end,
})

-- incrementing/decrementing numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement numebr" }) -- decrement

--when using these binds you can move a chunk of text and it will automatically indent
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- Custom useful keymaps
keymap.set("n", "<leader>km", "<cmd>Telescope keymaps<CR>", { desc = "Open keymap finder" })
keymap.set("n", "<leader>cn", "<cmd>Noice dismiss<CR>", { desc = "Clears notifications" })

-- copilot chat
keymap.set("n", "<leader>cc", function()
	require("CopilotChat").open()
end, { desc = "Open Copilot Chat" })

keymap.set("v", "<leader>ce", function()
	require("CopilotChat").open_selection()
end, { desc = "Ask Copilot about selection" })
