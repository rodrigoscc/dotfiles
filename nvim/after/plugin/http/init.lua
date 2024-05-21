local Http = require("after.plugin.http.http")
local project = require("after.plugin.http.project")
local hooks = require("after.plugin.http.hooks")
local display = require("after.plugin.http.display")
local Source = require("after.plugin.http.source").Source
local SourceType = require("after.plugin.http.source").type
local id = require("after.plugin.http.requests").id

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local conf = require("telescope.config").values

local http = Http.new()

vim.api.nvim_create_user_command("HttpRunClosest", function()
	local cursor_line = unpack(vim.api.nvim_win_get_cursor(0))

	local source = Source.new(SourceType.BUFFER, 0)
	local closest_request = source:get_closest_request(cursor_line)

	if closest_request then
		http:run(closest_request)
	end
end, {})

local function get_variable_name_under_cursor()
	local node = vim.treesitter.get_node()

	assert(node ~= nil, "There must be a node here.")

	if node:type() ~= "variable_ref" then
		return nil
	end

	local node_text =
		vim.trim(vim.treesitter.get_node_text(node, vim.fn.bufnr()))
	return string.sub(node_text, 3, #node_text - 2)
end

vim.api.nvim_create_user_command("HttpInspect", function()
	local variable_name = get_variable_name_under_cursor()

	if variable_name == nil then
		return
	end

	local cursor_line = unpack(vim.api.nvim_win_get_cursor(0))

	local source = Source.new(SourceType.BUFFER, 0)
	local closest_request = source:get_closest_request(cursor_line)

	if closest_request then
		local request_context = source:get_request_context(closest_request)
		local env_context = project:get_env_variables()

		local context = vim.tbl_extend("force", request_context, env_context)

		local value = context[variable_name]

		if value == nil then
			value = ""
		end

		display.show_in_floating(value)
	end
end, {})

vim.api.nvim_create_user_command("HttpRun", function()
	local requests = project.get_requests()

	pickers
		.new({}, {
			prompt_title = "Run HTTP request",
			finder = finders.new_table({
				results = requests,
				entry_maker = function(request)
					local line, _, _ = request.node:start()

					return {
						value = id(request),
						ordinal = id(request),
						display = id(request),
						filename = request.source.route,
						lnum = line + 1,
						request = request,
					}
				end,
			}),
			previewer = conf.grep_previewer({}),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				local run_selected_request = function()
					actions.close(prompt_bufnr)

					local selection =
						require("telescope.actions.state").get_selected_entry()

					http:run(selection.request)
				end

				map("i", "<CR>", run_selected_request)
				map("n", "<CR>", run_selected_request)

				return true
			end,
		})
		:find()
end, {})

vim.api.nvim_create_user_command("HttpJump", function()
	local requests = project.get_requests()

	pickers
		.new({}, {
			prompt_title = "Jump to HTTP request",
			finder = finders.new_table({
				results = requests,
				entry_maker = function(request)
					local line, _, _ = request.node:start()

					return {
						value = id(request),
						ordinal = id(request),
						display = id(request),
						filename = request.source.route,
						lnum = line + 1,
					}
				end,
			}),
			previewer = conf.grep_previewer({}),
			sorter = require("telescope.config").values.generic_sorter({}),
		})
		:find()
end, {})

vim.api.nvim_create_user_command("HttpRunLast", function()
	http:run_last()
end, {})

vim.api.nvim_create_user_command("HttpActivateEnv", function()
	local envs = project.get_existing_envs()
	local available_envs = vim.tbl_keys(envs)

	vim.ui.select(
		available_envs,
		{ prompt = "Activate environment" },
		function(selected_env)
			if selected_env ~= nil then
				project.activate_env(selected_env)
			end
		end
	)
end, {})

vim.api.nvim_create_user_command("HttpNewEnv", function()
	vim.ui.input({ prompt = "New environment" }, function(new_env)
		if new_env == nil then
			return
		end

		project.new_env(new_env)
	end)
end, {})

vim.api.nvim_create_user_command("HttpJumpEnv", function()
	local envs = project.get_existing_envs()
	local available_envs = vim.tbl_keys(envs)

	vim.ui.select(
		available_envs,
		{ prompt = "Jump to env" },
		function(selected_env)
			if selected_env ~= nil then
				project.open_env(selected_env)
			end
		end
	)
end, {})

vim.api.nvim_create_user_command("HttpOpenHooks", function()
	hooks.open_hooks_file()
end, {})

-- Keymaps
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "http",
	callback = function()
		vim.keymap.set("n", "R", "<cmd>HttpRunClosest<cr>", { buffer = true })
		vim.keymap.set("n", "K", "<cmd>HttpInspect<cr>", { buffer = true })
	end,
})

vim.keymap.set("n", "gh", "<cmd>HttpJump<cr>")
vim.keymap.set("n", "gH", "<cmd>HttpRun<cr>")
vim.keymap.set("n", "gL", "<cmd>HttpRunLast<cr>")

vim.keymap.set("n", "<leader>ee", "<cmd>HttpActivateEnv<cr>")
vim.keymap.set("n", "<leader>ne", "<cmd>HttpNewEnv<cr>")
vim.keymap.set("n", "<leader>oe", "<cmd>HttpJumpEnv<cr>")

vim.keymap.set("n", "<leader>oh", "<cmd>HttpOpenHooks<cr>")
