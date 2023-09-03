local M = {}

local cnf = require("tips.config")

local function create_floating_window()
	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = 80,
		height = 10,
		row = 10,
		col = 10,
		style = "minimal",
	})

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
		"Column 1\tColumn 2\tColumn 3",
		"-------\t-------\t-------",
		"Value A\tValue B\tValue C",
		"Value D\tValue E\tValue F",
		"Value G\tValue H\tValue I",
	})

	return winid
end

function M.toggle()
	create_floating_window()
end

function M.setup(custom_opts)
	vim.api.nvim_set_keymap("n", "<leader>ot", "<Cmd> TipsToggle <CR>", { noremap = true })

	cnf:set_options(custom_opts)
end

return M
