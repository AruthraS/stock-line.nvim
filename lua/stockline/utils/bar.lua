local M = {}

M.Bar = {}
M.Bar.__index = M.Bar

local api = vim.api

function M.Bar:new()
	local instance = setmetatable({}, self)
	return instance
end

function M.Bar:create(ticker, exchange, bgColor, fontColor)
	local win_width = vim.o.columns
	local win_height = api.nvim_win_get_height(0)

	-- Clear previous buffer and window
	if self.buf and api.nvim_buf_is_valid(self.buf) then
		api.nvim_buf_delete(self.buf, { force = true })
		self.buf = nil
	end
	if self.bar and api.nvim_win_is_valid(self.bar) then
		api.nvim_win_close(self.bar, true)
		self.bar = nil
	end

	-- Create buffer
	bgColor = bgColor or "#fc4103"
	fontColor = fontColor or "#000000"
	vim.cmd(string.format("highlight barcolor guibg=%s guifg=%s", bgColor, fontColor))

	local create_buf = function()
		local price_fetch = require("stockline.utils.price_fetch")
		self.buf = api.nvim_create_buf(false, true)
		local price = price_fetch.fetch(ticker, exchange)
		local text = ticker .. " : " .. price
		local text_length = vim.fn.strwidth(text)
		local space_len = win_width - text_length
		local padded_text = string.rep(" ", space_len / 2) .. text .. string.rep(" ", space_len / 2 + space_len % 2)
		api.nvim_buf_set_lines(self.buf, 0, -1, false, { padded_text })
		api.nvim_buf_clear_namespace(self.buf, -1, 0, -1)
		api.nvim_buf_add_highlight(self.buf, -1, "barcolor", 0, 0, -1)
	end

	create_buf()

	-- Window
	local window = {
		relative = "editor",
		width = win_width,
		height = 1,
		row = win_height,
		col = 0,
		style = "minimal",
		border = "none",
	}
	local win_create = function()
		self.bar = api.nvim_open_win(self.buf, false, window)

		-- Timer to update text
		self.timer = vim.loop.new_timer()
		self.timer:start(
			0,
			30000,
			vim.schedule_wrap(function()
				if self.buf and api.nvim_buf_is_valid(self.buf) then
					create_buf()
				end
			end)
		)
	end

	win_create()
	-- Autocmd
	if not self._autocmd_created then
		api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			callback = function()
				local cursor_row, _ = unpack(api.nvim_win_get_cursor(0))
				local win_top_line = vim.fn.line("w0")
				local cursor_line = cursor_row - win_top_line + 1
				if self.bar and api.nvim_win_is_valid(self.bar) then
					if cursor_line == win_height then
						api.nvim_win_close(self.bar, true)
						self.bar = nil
						if self.timer then
							self.timer:stop()
							self.timer:close()
							self.timer = nil
						end
					end
				elseif cursor_line ~= win_height then
					win_create()
				end
			end,
		})
		self._autocmd_created = true
	end
end

return M
