vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.y",
	command = "source yacc.vim",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.dgo",
	callback = function()
		vim.cmd("set filetype=go")
		vim.cmd("ASToggle")
		vim.cmd("FormatDisable")
	end,
})
