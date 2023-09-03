local command = vim.api.nvim_create_user_command

command("TipsToggle", function()
	require("tips").toggle()
end, {})
