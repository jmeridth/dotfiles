return {
  "saghen/blink.cmp",
  version = "*",
  opts = {
    keymap = { preset = "default" },
    appearance = { use_nvim_cmp_as_default = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = { auto_show = true },
    },
  },
}
