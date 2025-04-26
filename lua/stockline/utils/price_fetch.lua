local M = {}

M.fetch = function(ticker, exchange)
	local path = vim.api.nvim_get_runtime_file("lua/stockline/utils/price_fetch.py", false)[1]
	local result = vim.fn.system({ "python3", path, ticker, exchange })
	return result:gsub("\n", "")
end

return M
