local M = {}

function M.setup(opts)
	opts = opts or {}
	local api = vim.api
	local bar = require("stockline.utils.bar")
	local fn = vim.fn
	local sys = fn.system

	local get_plugin_dir = function()
		local path = debug.getinfo(1, "S").source:sub(2)
		return fn.fnamemodify(path, ":h:h:h")
	end

	local ensure_venv = function()
		local plugin_dir = get_plugin_dir()
		local venv_path = plugin_dir .. "/venv"
		local is_windows = vim.loop.os_uname().version:match("Windows")
		local python_exe = is_windows and (venv_path .. "/Scripts/python.exe") or (venv_path .. "/bin/python")
		if fn.isdirectory(venv_path) == 0 then
			api.nvim_out_write("Creating Virtual environment for stockline plugin")
			sys({ "python", "-m", "venv", venv_path })
			sys({ python_exe, "-m", "pip", "install", "requests", "beautifulsoup4" })
			api.nvim_out_write("Created Virtual environment")
		end
		return python_exe
	end

	local python_exe = ensure_venv()

	local o = bar.Bar:new()

	if opts.ticker and opts.exchange then
		api.nvim_create_autocmd({ "VimEnter", "TabEnter", "VimResized" }, {
			pattern = "*",
			callback = function()
				vim.defer_fn(function()
					o:create(opts.ticker, opts.exchange, opts.bgColor, opts.fontColor, python_exe)
				end, 20)
			end,
		})
	else
		print("Provide appropriate Ticker and Exchange symbol stock-line plugin")
	end
end

return M
