-- In your Lazy.nvim config
return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "neovim"              -- Use Neovim terminal instead of tmux
    vim.g.slime_python_ipython = 1             -- Enable IPython-compatible formatting
    -- Remove slime_default_config; it's for tmux only
  end
}
