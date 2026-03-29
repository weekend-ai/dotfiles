-- Add your custom plugins here
return {
  -- Show hidden files in snacks picker and explorer
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          explorer = {
            hidden = true,
          },
          grep = {
            hidden = true,
          },
        },
      },
    },
  },
}
