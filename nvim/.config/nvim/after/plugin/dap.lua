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
		name = "Debug",
		request = "launch",
		program = "${file}",
	},
}
