local M = {}

function M.setup(opts)
	opts = opts or {}
	local api = vim.api
	local bar = require("stockline.utils.bar")

	local o = bar.Bar:new()

	if opts.ticker and opts.exchange then
		api.nvim_create_autocmd({ "VimEnter", "TabEnter", "VimResized" }, {
			pattern = "*",
			callback = function()
				vim.defer_fn(function()
					o:create(opts.ticker, opts.exchange)
				end, 20)
			end,
		})
	else
		print("Provide appropriate Ticker and Exchange symbol stock-line plugin")
	end
end

return M
