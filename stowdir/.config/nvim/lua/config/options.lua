-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Options are automatically loaded before lazy.nvim startup
vim.opt.relativenumber = false
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("open_explorer", {}),
  callback = function()
    -- Open scoped to the file's root directory
    -- Snacks.explorer({ cwd = LazyVim.root(), enter = false })

    -- Open scoped to the pwd
    local picker = Snacks.explorer.reveal({ buf = 0 })
    picker.opts.hidden = true
    picker.opts.enter = false
  end,
})
