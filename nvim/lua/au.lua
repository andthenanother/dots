local au = vim.api.nvim_create_autocmd
local gr = vim.api.nvim_create_augroup('config', {})

-- Set on `Filetype` else will be overwritten by ftplugin defaults
au('FileType', { group = gr, command = 'set fo-=c fo-=t fo-=o' })

local ignored_fts = { 'gitcommit', 'gitrebase', 'makefile' }

local function restore_cursor()
	if vim.bo.buftype ~= '' or vim.tbl_contains(ignored_fts, vim.bo.ft) then
		return
	end

	local mark = vim.api.nvim_buf_get_mark(0, '"')
	local lcount = vim.api.nvim_buf_line_count(0)
	if mark[1] > 0 and mark[1] <= lcount then
		pcall(vim.api.nvim_win_set_cursor, 0, mark)
	end

	vim.cmd('normal! zz')
end

au('BufReadPost', { group = gr, callback = restore_cursor })

local function clear_hls()
	if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
		vim.schedule(vim.cmd.nohlsearch)
	end
end
au('CursorMoved', { group = gr, callback = clear_hls })

local formatter = vim.api.nvim_create_augroup('formatter.config', {})
au('BufWritePre', {
	group = formatter,
	callback = function()
		local cursor = vim.api.nvim_win_get_cursor(0)
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.api.nvim_win_set_cursor(0, cursor)

		if vim.bo.ft ~= 'markdown' then
			local n_lines = vim.api.nvim_buf_line_count(0)
			local last_nonblank = vim.fn.prevnonblank(n_lines)
			if last_nonblank < n_lines then
				vim.api.nvim_buf_set_lines(0, last_nonblank, n_lines, true, {})
			end
		end
	end,
})

au('TextYankPost', {
	group = gr,
	callback = function()
		vim.hl.on_yank({ higroup = 'visual' })

		if vim.v.operator == 'y' then
			for r = 9, 1, -1 do
				vim.fn.setreg(tostring(r), vim.fn.getreg(tostring(r - 1)))
			end
		end
	end,
})

local root_names = { '.git', 'Makefile' }
local root_cache = {}

local function set_root()
	local path = vim.api.nvim_buf_get_name(0)
	if path == '' then
		return
	end
	path = vim.fs.dirname(path)

	local root = root_cache[path]
	if not root then
		local root_file = vim.fs.find(root_names, { path = path, upward = true })[1]
		if not root_file then
			return
		end
		root = vim.fs.dirname(root_file)
		root_cache[path] = root
	end
	vim.fn.chdir(root)
end

local rooter = vim.api.nvim_create_augroup('rooter.config', {})
au('BufEnter', { group = rooter, callback = set_root })

local function lsp_config(ev)
	local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

	if client:supports_method('textDocument/documentColor', ev.buf) then
		vim.lsp.document_color.enable(true, ev.buf, { style = 'virtual' })
	end
end

local attach = vim.api.nvim_create_augroup('lsp.config', {})
au('LspAttach', { group = attach, callback = lsp_config })
