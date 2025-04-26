local M = {}

M.Bar = {}
M.Bar.__index = M.Bar

local api = vim.api

function M.Bar:new()
	local instance = setmetatable({}, self)
	return instance
end

function M.Bar:create(ticker, exchange)
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
	local price_fetch = require("stockline.utils.price_fetch")
	self.buf = api.nvim_create_buf(false, true)
	local text = price_fetch.fetch(ticker, exchange)
	local text_length = vim.fn.strwidth("" .. text)
	local padded_text = text .. string.rep(" ", win_width - text_length)
	api.nvim_buf_set_lines(self.buf, 0, -1, false, { padded_text })

	-- Highlight
	vim.cmd("highlight barcolor guibg=#303446 guifg=#ffffff")
	api.nvim_buf_add_highlight(self.buf, -1, "barcolor", 0, 0, -1)

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
			10000,
			vim.schedule_wrap(function()
				if self.buf and api.nvim_buf_is_valid(self.buf) then
					local new_text = price_fetch.fetch(ticker, exchange)
					local new_text_length = vim.fn.strwidth("" .. new_text)
					local new_padded_text = new_text .. string.rep(" ", win_width - new_text_length)
					api.nvim_buf_set_lines(self.buf, 0, -1, false, { new_padded_text })
					api.nvim_buf_clear_namespace(self.buf, -1, 0, -1)
					api.nvim_buf_add_highlight(self.buf, -1, "barcolor", 0, 0, -1)
				end
			end)
		)
	end

	win_create()
	-- Autocmd
	if not self._autocmd_created then
		api.nvim_create_autocmd("CursorMoved", {
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
