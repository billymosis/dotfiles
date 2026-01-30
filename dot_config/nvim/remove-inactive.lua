local inactive_plugins = vim.iter(vim.pack.get())
  :filter(function(x) return not x.active end)
  :map(function(x) return x.spec.name end)
  :totable()

-- vim.print(inactive_plugins)
vim.pack.del(inactive_plugins)
