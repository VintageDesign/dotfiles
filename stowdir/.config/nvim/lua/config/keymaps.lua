-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Disable moving lines with Alt + Arrow Keys
-- We use vim.schedule to ensure this runs AFTER LazyVim's core defaults are set
vim.schedule(function()
  local modes = { "n", "i", "v" }
  local keys = { "<A-j>", "<A-k>", "<A-Up>", "<A-Down>" }

  for _, mode in ipairs(modes) do
    for _, key in ipairs(keys) do
      pcall(vim.keymap.del, mode, key)
    end
  end
end)
