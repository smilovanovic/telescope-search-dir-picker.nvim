local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

return telescope.register_extension({
	setup = function(ext_config, config)
		-- access extension config and user config
	end,
	exports = {
		search_dir_picker = require("telescope._extensions.search_dir_picker.main").search_dir,
	},
})
