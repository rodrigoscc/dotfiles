local http = require("after.plugin.http.http")
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

---@class HttpSubcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

---@type table<string, HttpSubcommand>
local subcommand_tbl = {
	run_closest = {
		impl = function(args, opts)
			local cursor_line = unpack(vim.api.nvim_win_get_cursor(0))

			local source = Source.new(SourceType.BUFFER, 0)
			local closest_request = source:get_closest_request(cursor_line)

			if closest_request then
				http:run(closest_request)
			end
		end,
	},
	inspect = {
		impl = function(args, opts)
			local variable_name = get_variable_name_under_cursor()

			if variable_name == nil then
				return
			end

			local cursor_line = unpack(vim.api.nvim_win_get_cursor(0))

			local source = Source.new(SourceType.BUFFER, 0)
			local closest_request = source:get_closest_request(cursor_line)

			if closest_request then
				local request_context =
					source:get_request_context(closest_request)
				local env_context = project:get_env_variables()

				local context =
					vim.tbl_extend("force", request_context, env_context)

				local value = context[variable_name]

				if value == nil then
					value = ""
				end

				display.show_in_floating(value)
			end
		end,
	},
	run = {
		impl = function(args, opts)
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
		end,
	},
	jump = {
		impl = function(args, opts)
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
		end,
	},
	run_last = {
		impl = function(args, opts)
			http:run_last()
		end,
	},
	activate_env = {
		impl = function(args, opts)
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
		end,
	},
	new_env = {
		impl = function(args, opts)
			vim.ui.input({ prompt = "New environment" }, function(new_env)
				if new_env == nil then
					return
				end

				project.new_env(new_env)
			end)
		end,
	},
	jump_env = {
		impl = function(args, opts)
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
		end,
	},
	open_hooks = {
		impl = function(args, opts)
			hooks.open_hooks_file()
		end,
	},
}

---@param opts table :h lua-guide-commands-create
local function http_cmd(opts)
	local fargs = opts.fargs

	local subcommand_name = fargs[1]
	local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}

	local subcommand = subcommand_tbl[subcommand_name]

	if not subcommand then
		vim.notify(
			"Http: Unknown command: " .. subcommand_name,
			vim.log.levels.ERROR
		)
		return
	end

	subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command("Http", http_cmd, {
	nargs = "+",
	desc = "Run Http commands",
	complete = function(arg_lead, cmdline, _)
		local subcmd_key, subcmd_arg_lead =
			cmdline:match("^['<,'>]*Http%s(%S+)%s(.*)$")

		local subcmd_has_completions = subcmd_key
			and subcmd_arg_lead
			and subcommand_tbl[subcmd_key]
			and subcommand_tbl[subcmd_key].complete

		if subcmd_has_completions then
			return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
		end

		local is_subcmd = cmdline:match("^['<,'>]*Http%s+%w*$")
		if is_subcmd then
			local subcommand_names = vim.tbl_keys(subcommand_tbl)

			return vim.iter(subcommand_names)
				:filter(function(key)
					return key:find(arg_lead) ~= nil
				end)
				:totable()
		end
	end,
})

-- Keymaps
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "http",
	callback = function()
		vim.keymap.set("n", "R", "<cmd>Http run_closest<cr>", { buffer = true })
		vim.keymap.set("n", "K", "<cmd>Http inspect<cr>", { buffer = true })
	end,
})

vim.keymap.set("n", "gh", "<cmd>Http jump<cr>")
vim.keymap.set("n", "gH", "<cmd>Http run<cr>")
vim.keymap.set("n", "gL", "<cmd>Http run_last<cr>")

vim.keymap.set("n", "<leader>ee", "<cmd>Http activate_env<cr>")
vim.keymap.set("n", "<leader>ne", "<cmd>Http new_env<cr>")
vim.keymap.set("n", "<leader>oe", "<cmd>Http jump_env<cr>")

vim.keymap.set("n", "<leader>oh", "<cmd>Http open_hooks<cr>")

local cmp = require("cmp")
local http_cmp_source = require("after.plugin.http.cmp_source")

cmp.register_source("http", http_cmp_source)
cmp.setup.filetype("http", {
	sources = cmp.config.sources({
		{ name = "http" },
	}, {
		{ name = "buffer" },
		{ name = "path" },
		{ name = "luasnip", keyword_length = 2 },
	}),
})
