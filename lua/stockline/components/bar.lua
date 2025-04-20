local M = {}

M.create = function()
	local o = vim.o
	o.showtabline = 2
	o.tabline = "Hello..."
end

return M
