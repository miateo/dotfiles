require("miateo.core")
require("miateo.lazy")
vim.opt.autoread = true
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
  pattern = "*",
  command = "checktime",
})
