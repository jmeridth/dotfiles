return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "go",
      "terraform",
      "markdown",
      "markdown_inline",
      "lua",
      "vim",
      "vimdoc",
    })
  end,
}
