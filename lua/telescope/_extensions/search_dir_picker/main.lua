local builtin = require("telescope.builtin")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local Path = require("plenary.path")
local os_sep = Path.path.sep

local M = {}

-- Doesn't respect .gitignore which leads to many results and slowness
M.get_dirs_recursive = function(path)
	local results = {}
	for name, type in vim.fs.dir(path) do
		if type == "directory" then
			local dir_path = Path:new(path .. os_sep .. name)
			results[#results + 1] = dir_path:make_relative(vim.fn.getcwd())
			local children = M.get_dirs_recursive(dir_path:absolute())
			for _, v in ipairs(children) do
				results[#results + 1] = Path:new(path .. os_sep .. v):make_relative(vim.fn.getcwd())
			end
		end
	end
	return results
end

M.search_dir = function(opts)
	opts = opts or {}
	pickers
		.new(require("telescope.themes").get_dropdown(opts), {
			prompt_title = "Search directory",
			finder = finders.new_oneshot_job({ "tree", "-d", "-i", "-f", "--gitignore", "--noreport" }, opts),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					builtin.live_grep({
						prompt_title = "Live Grep in: " .. selection[1],
						search_dirs = { selection[1] },
					})
				end)
				return true
			end,
		})
		:find()
end

return M
