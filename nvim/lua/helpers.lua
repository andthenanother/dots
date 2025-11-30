local H = {}

--- @param msg string|string[]
--- @param level ('DEBUG'|'TRACE'|'INFO'|'WARN'|'ERROR')?
function H.notify(msg, level)
	msg = type(msg) == 'table' and table.concat(msg, '\n') or msg
	vim.notify(msg, vim.log.levels[level or 'info'])
	vim.cmd.redraw({ bang = true })
end

--- @type string[]
local dir = { 'assets' }
--- @type table<string, string>
local dir_cache = {}

--- @return string
function H.get_img_dir()
	local fpath = vim.api.nvim_buf_get_name(0)

	local full_path = dir_cache[fpath]
	if not full_path then
		local path = vim.fs.dirname(fpath)
		local img_dir = vim.fs.find(dir, {
			path = path,
			upward = true,
		})[1]

		full_path = img_dir and vim.fs.joinpath(img_dir, vim.fn.fnamemodify(fpath, ':t:r'))
		dir_cache[fpath] = full_path
	end

	return full_path
end

function H.image_delete()
	local line = vim.api.nvim_get_current_line()
	local start_col, end_col, image = line:find('^%!%[.-%]%((.-)%)')

	if not image or image == '' then
		return H.notify('Not an image', 'WARN')
	end
	if image:find('^%w%w+://') then
		return H.notify('Remote URL', 'ERROR')
	end

	local path = vim.fs.joinpath(H.get_img_dir(), vim.fs.basename(H.unescape(image)))
	if not vim.uv.fs_stat(path) then
		return H.notify('Invalid path', 'ERROR')
	end

	local msg = 'CONFIRM IMAGE DELETION?\n'
	local res = vim.fn.confirm(msg, '&Yes\n&No', 2, 'Question')
	if res ~= 1 then
		return
	end

	local out = vim.system({ 'trash', path }, {}):wait()
	if out.code ~= 0 then
		return
	end

	local y = vim.fn.line('.') - 1 --> 0-index
	--- @diagnostic disable-next-line: param-type-mismatch
	vim.api.nvim_buf_set_text(0, y, start_col - 1, y, end_col, {})

	local empty = vim.api.nvim_buf_get_lines(0, y, y + 1, false)[1]:find('^%s*$')
	if empty then
		vim.api.nvim_buf_set_lines(0, y, y + 1, false, {})
	end

	vim.cmd('silent! update')
end

--- @param buf number?
function H.bufremove(buf)
	buf = buf or 0
	buf = buf == 0 and vim.api.nvim_get_current_buf() or buf

	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.api.nvim_win_call(win, function()
			if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
				return
			end

			local alt_buf = vim.fn.bufnr('#')
			if alt_buf ~= buf and vim.fn.buflisted(alt_buf) == 1 then
				vim.api.nvim_win_set_buf(win, alt_buf)
				return
			end

			local has_previous = pcall(vim.cmd, 'bprevious') --- @diagnostic disable-line param-type-mismatch
			if has_previous and buf ~= vim.api.nvim_win_get_buf(win) then
				return
			end

			local new_buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_win_set_buf(win, new_buf)
		end)
	end
	if vim.api.nvim_buf_is_valid(buf) then
		pcall(vim.cmd, 'bdelete! ' .. buf) --- @diagnostic disable-line param-type-mismatch
	end
end

H.hex_to_char = function(x)
	return string.char(tonumber(x, 16))
end
H.unescape = function(x)
	return x:gsub('%%(%x%x)', H.hex_to_char)
end

H.now = vim.fn.argc(-1) > 0 and MiniDeps.now or MiniDeps.later

return H
