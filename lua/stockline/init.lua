local M = {}

function M.setup(opts)
	opts = opts or {}
	local api = vim.api
	local bar = require("stockline.utils.bar")
	local sys = vim.fn.system
	local chk_pkg = function(pkg)
		local is_present = sys("pip show " .. pkg):gsub("%s+$", "")
		if is_present:find("WARNING") then
			sys("pip install " .. pkg)
		end
	end
	chk_pkg("requests")
	chk_pkg("bs4")

	local o = bar.Bar:new()

	if opts.ticker and opts.exchange then
		api.nvim_create_autocmd({ "VimEnter", "TabEnter", "VimResized" }, {
			pattern = "*",
			callback = function()
				vim.defer_fn(function()
					o:create(opts.ticker, opts.exchange, opts.bgColor, opts.fontColor)
				end, 20)
			end,
		})
	else
		print("Provide appropriate Ticker and Exchange symbol stock-line plugin")
	end
end

return M
