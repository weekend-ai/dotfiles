-- Options are automatically loaded before lazy.nvim startup
-- Add any additional options here

-- Auto-open snacks explorer when opening a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.schedule(function()
        vim.cmd("bwipeout")
        Snacks.explorer.open()
      end)
    end
  end,
})
