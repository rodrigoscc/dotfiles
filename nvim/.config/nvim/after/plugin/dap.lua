local dap = require("dap")

local function find_python_path()
	if vim.uv.fs_stat(".venv") then
		return ".venv/bin/python"
	else
		return os.getenv("HOME") .. "/.venvs/tools/bin/python"
	end
end

dap.adapters.debugpy = function(callback, config)
	callback({
		type = "executable",
		command = find_python_path(),
		args = { "-m", "debugpy.adapter" },
	})
end

dap.configurations.python = {
	{
		type = "debugpy",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = find_python_path,
	},
}

dap.adapters.go = function(callback, config)
	callback({
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = {
			command = "dlv",
			args = { "dap", "--listen", "127.0.0.1:${port}" },
		},
	})
end

dap.configurations.go = {
	{
		type = "go",
		name = "Debug file",
		request = "launch",
		program = "${file}",
		outputMode = "remote", -- send output to REPL view
	},
}

-- JavaScript/TypeScript debugging via vscode-js-debug
local js_debug_path = vim.fn.stdpath("data")
	.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "node",
		args = { js_debug_path, "${port}" },
	},
}

dap.adapters["pwa-chrome"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "node",
		args = { js_debug_path, "${port}" },
	},
}

local js_configurations = {
	{
		type = "pwa-node",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		cwd = "${workspaceFolder}",
	},
	{
		type = "pwa-node",
		request = "attach",
		name = "Attach to Node (9229)",
		port = 9229,
		cwd = "${workspaceFolder}",
	},
	{
		type = "pwa-node",
		request = "attach",
		name = "Attach to Node (9230)",
		port = 9230,
		cwd = "${workspaceFolder}",
	},
	{
		type = "pwa-chrome",
		request = "launch",
		name = "Launch Chrome (localhost:3000)",
		url = "http://localhost:3000",
	},
	{
		type = "pwa-chrome",
		request = "launch",
		name = "Launch Chrome (localhost:5173)",
		url = "http://localhost:5173",
	},
}

dap.configurations.javascript = js_configurations
dap.configurations.typescript = js_configurations
dap.configurations.typescriptreact = js_configurations
dap.configurations.javascriptreact = js_configurations
