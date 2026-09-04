# Neovim config (miateo)

Portable between Arch Linux and macOS. Drop this folder at `~/.config/nvim` on either OS; first launch will install plugins + LSPs via lazy.nvim + Mason.

## External dependencies

You need these on the system before launching nvim:

### Arch Linux
```sh
sudo pacman -S --needed neovim ripgrep fd base-devel git nodejs npm python-pynvim tree-sitter xclip wl-clipboard
# Tree-sitter CLI (from github release, not in repos):
curl -sL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz | gunzip | sudo tee /usr/local/bin/tree-sitter >/dev/null && sudo chmod +x /usr/local/bin/tree-sitter
```

### macOS (Homebrew)
```sh
xcode-select --install
brew install neovim ripgrep fd node tree-sitter
```

And install a Nerd Font (e.g. JetBrainsMono Nerd Font) — required for icons in Telescope, lualine, nvim-tree.

## Install

```sh
git clone https://github.com/miateo/dotfiles ~/dotfiles
ln -sfn ~/dotfiles/nvim ~/.config/nvim
nvim     # first launch auto-installs everything (~2 min)
```

## Layout

- `init.lua` — entrypoint, loads core + lazy
- `lua/miateo/core/` — options, keymaps
- `lua/miateo/lazy.lua` — plugin manager setup
- `lua/miateo/plugins/` — one file per plugin
- `lua/miateo/plugins/lsp/` — LSP (mason + lspconfig)
- `lazy-lock.json` — plugin commit pins (keeps Mac/Linux in sync)

## Notes

- nvim-treesitter is pinned to v0.9.3 in `plugins/treesitter.lua` because the 1.0 rewrite changed the API.
- Mason auto-picks the correct LSP binary per OS. Nothing to configure.
- Run `:Lazy sync` after pulling repo updates.
- If telescope-fzf-native fails: `:Lazy build telescope-fzf-native.nvim`.
