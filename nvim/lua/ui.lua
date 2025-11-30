local H = {}

vim.o.statusline = "%!v:lua.require('ui').render()"

local ignored_fts = { 'nvim-undotree' }

function H.render()
	if vim.api.nvim_buf_get_name(0) == '' then
		return ''
	end
	if vim.tbl_contains(ignored_fts, vim.bo.ft) then
		return ''
	end

	if vim.bo.ft == 'markdown' then
		return table.concat({
			'%=',
			H.mod_status(),
		}, ' ')
	end

	if vim.g.statusline_winid ~= vim.api.nvim_get_current_win() then
		return ''
	end

	return table.concat({
		'%f',
		H.type_icon(),
		'%=',
		H.mod_status(),
		H.cursor_position(),
	}, ' ')
end

function H.type_icon()
	local icon, hl

	local ok, miniicons = pcall(require, 'mini.icons')
	if ok then
		icon, hl = miniicons.get('filetype', vim.bo.ft or '')
		if vim.bo.ft ~= '' then
			return H.create_item(icon, hl)
		end
	end

	return ''
end

function H.cursor_position()
	-- Use `virtcol()` to handle virtual edit
	local x, y = vim.fn.virtcol('.'), vim.fn.line('.')
	local visual_mode = vim.api.nvim_get_mode().mode:match('^[vV\22]')
	local visual_lines = math.abs(y - vim.fn.line('v')) + 1

	local total = visual_mode and visual_lines or vim.api.nvim_buf_line_count(0)

	return ('%d|%d|%d'):format(y, x, total)
end

function H.mod_status()
	if vim.bo.modified then return '' end

	local current_buf = vim.api.nvim_get_current_buf()
	for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
		if buf_id ~= current_buf and vim.bo[buf_id].buflisted and vim.bo[buf_id].modified then
			return ''
		end
	end

	return ''
end

function H.create_item(cmp, hl_group)
	if not cmp then return '' end
	hl_group = hl_group or 'StatusLine'
	return ('%%#%s#%s%%#StatusLine#'):format(hl_group, cmp)
end

-- Credit: https://github.com/lewis6991/dotfiles/blob/0071d6f1a97f8f6080eb592c4838d92f77901e84/config/nvim/lua/gizmos/marksigns.lua
local namespace = vim.api.nvim_create_namespace('marks')
function H.decor_mark(bufnr, mark)
	pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, mark.pos[2] - 1, 0, {
		sign_text = mark.mark:sub(2),
		sign_hl_group = '',
	})
end

vim.api.nvim_set_decoration_provider(namespace, {
	on_win = function(_, _, bufnr, top_row, bot_row)
		if vim.api.nvim_buf_get_name(bufnr) == '' then
			return
		end

		vim.api.nvim_buf_clear_namespace(bufnr, namespace, top_row, bot_row)

		local current_file = vim.api.nvim_buf_get_name(bufnr)

		for _, mark in ipairs(vim.fn.getmarklist()) do
			if mark.mark:match('^.[a-zA-Z]$') then
				local mark_file = vim.fn.fnamemodify(mark.file, ':p:a')
				if current_file == mark_file then H.decor_mark(bufnr, mark) end
			end
		end

		for _, mark in ipairs(vim.fn.getmarklist(bufnr)) do
			if mark.mark:match('^.[a-zA-Z]$') then H.decor_mark(bufnr, mark) end
		end
	end,
})

vim.on_key(function(_, typed)
	if typed:sub(1, 1) ~= 'm' then
		return
	end

	local mark = typed:sub(2)

	vim.schedule(function()
		if mark:match('[A-Z]') then
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				vim.api.nvim__redraw({ win = win, range = { 0, -1 } })
			end
		else
			vim.api.nvim__redraw({ range = { 0, -1 } })
		end
	end)
end, namespace)


vim.api.nvim_set_hl(0, 'FloatTitle', { bg = 'none' })
vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'none' })

return H
