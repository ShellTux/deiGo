vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.y",
	callback = function()
		vim.cmd [[source yacc.vim]]
		vim.cmd [[setlocal commentstring=//\ %s]]
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.l",
	callback = function()
		vim.cmd [[setlocal commentstring=//\ %s]]
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.dgo",
	callback = function()
		vim.cmd("set filetype=go")
		vim.cmd("ASToggle")
		vim.cmd("FormatDisable")
	end,
})
