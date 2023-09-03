Config = {
	opts = {
		enabled = true, -- start  when the plugin is loaded (i.e. when your package manager loads it)
	},
}

function Config:set_options(opts)
	opts = opts or {}
	self.opts = vim.tbl_deep_extend("keep", opts, self.opts)
end

function Config:get_options()
	return self.opts
end

return Config
