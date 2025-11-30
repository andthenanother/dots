local au = vim.api.nvim_create_autocmd
local u = require('helpers')
local gr = vim.api.nvim_create_augroup('spec.config', {})

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
	add({
		source = 'folke/noice.nvim',
		depends = { 'MunifTanjim/nui.nvim' },
	})

	require('noice').setup({
		presets = { command_palette = true },
		lsp = {
			progress = { enabled = false },
			hover = { enabled = false },
			signature = { enabled = false },
		},
		cmdline = {
			format = {
				cmdline = { title = '', icon = ':' },
				lua = false,
				search_down = false,
				search_up = false,
			},
		},
		messages = { view_search = false },
	})
end)

u.now(function()
	add({
		source = 'nvim-treesitter/nvim-treesitter',
		checkout = 'main',
		hooks = {
			post_checkout = function()
				vim.cmd('TSUpdate')
			end,
		},
	})

	local ensure_installed = {
		'bash', 'cpp', 'html', 'javascript', 'json', 'kdl', 'latex', 'python', 'r',
		'regex', 'rust', 'toml', 'typst', 'xml', 'yaml',
	}

	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, ensure_installed)
	if #to_install > 0 then
		require('nvim-treesitter').install(to_install)
	end

	local ft = vim.iter(ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()
	vim.list_extend(ft, { 'markdown', 'pandoc' })

	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	au('FileType', { group = gr, pattern = ft, callback = ts_start })
end)

now(function()
	add('nvim-mini/mini.tabline')
	require('mini.tabline').setup()
end)

later(function()
	add('nvim-mini/mini.icons')
	require('mini.icons').setup()
end)

later(function()
	add('nvim-mini/mini.ai')
	require('mini.ai').setup()
end)

now(function()
	add('nvim-mini/mini.pick')

	local function center()
		local height = math.floor(0.618 * vim.o.lines)
		local width = math.floor(0.618 * vim.o.columns)
		return {
			anchor = 'NW',
			height = height,
			width = width,
			row = math.floor(0.5 * (vim.o.lines - height)),
			col = math.floor(0.5 * (vim.o.columns - width)),
		}
	end

	require('mini.pick').setup({
		options = { use_cache = true },
		window = { config = center },
	})

	vim.keymap.set('n', '<Leader>b', MiniPick.builtin.buffers)
	vim.keymap.set('n', '<Leader>f', MiniPick.builtin.files)
	vim.keymap.set('n', '<Leader>h', MiniPick.builtin.help)
	vim.keymap.set('n', '<Leader>r', MiniPick.builtin.grep_live)
end)

later(function()
	add('zk-org/zk-nvim')

	require('zk').setup()

	vim.keymap.set('n', '<Leader>zf', "<Cmd>ZkNotes { sort = { 'modified' } }<CR>")
	vim.keymap.set('n', '<Leader>zi', '<Cmd>ZkIndex<CR>')
	vim.keymap.set('n', '<Leader>zn', "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>")
	vim.keymap.set('n', '<Leader>zr', "<Cmd>ZkTags { sort = { 'note-count' } }<CR>")
end)

later(function()
	add('nvim-mini/mini.files')

	require('mini.files').setup({
		mappings = {
			go_in_plus = '<CR>',
			go_out_plus = 'h',
			go_out = 'H',
		},
		options = { permanent_delete = false },
		windows = {
			max_number = 3,
			width_focus = 35,
		},
	})

	vim.keymap.set('n', 'vd', MiniFiles.open)

	vim.keymap.set('n', 'vc', function()
		local file = vim.api.nvim_buf_get_name(0)
		local file_exists = file ~= ''
		MiniFiles.open(file_exists and file or vim.uv.cwd(), false)
	end)

	local show = function()
		vim.ui.open(MiniFiles.get_fs_entry().path)
	end
	local set_cwd = function()
		vim.fn.chdir(vim.fs.dirname(MiniFiles.get_fs_entry().path))
	end

	local paste = function()
		local img = MiniFiles.get_fs_entry().path
		MiniFiles.close()

		require('img-clip').paste_image({
			copy_images = true,
			download_images = true,
		}, img)
	end

	local preview = function()
		local preview = MiniFiles.config.windows.preview
		local state = not preview

		MiniFiles.config.windows.preview = state
		MiniFiles.refresh({ windows = { preview = state } })

		if preview then
			local branch = MiniFiles.get_explorer_state().branch
			table.remove(branch)
			MiniFiles.set_branch(branch)
		end
	end

	local function set_opts(ev)
		local buf = ev.data.buf_id

		vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = buf })
		au('BufWriteCmd', {
			group = gr,
			buffer = buf,
			callback = function()
				MiniFiles.synchronize()
			end,
		})

		vim.keymap.set('n', 'gx', show, { buffer = buf })
		vim.keymap.set('n', 'g~', set_cwd, { buffer = buf })
		vim.keymap.set('n', '<M-v>', paste, { buffer = buf })
		vim.keymap.set('n', '<M-p>', preview, { buffer = buf })
	end
	au('User', { group = gr, pattern = 'MiniFilesBufferCreate', callback = set_opts })

	local function set_marks()
		MiniFiles.set_bookmark('h', '~')
		MiniFiles.set_bookmark('p', '~/Pictures/img')
		MiniFiles.set_bookmark('n', vim.env.ZK_NOTEBOOK_DIR)
		MiniFiles.set_bookmark('a', vim.env.ZK_NOTEBOOK_DIR .. '/assets')
		MiniFiles.set_bookmark('c', vim.fn.stdpath('config'))
	end
	au('User', { group = gr, pattern = 'MiniFilesExplorerOpen', callback = set_marks })
end)

later(function()
	add('Wansmer/treesj')
	vim.keymap.set('n', 'sj', require('treesj').toggle)
end)

later(function()
	add('stevearc/conform.nvim')

	require('conform').setup({
		formatters_by_ft = { lua = { 'stylua' } },
	})

	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end)

later(function()
	local build = function()
		vim.cmd('BlinkCmp build')
	end
	add({
		source = 'Saghen/blink.cmp',
		hooks = {
			post_install = function()
				later(build)
			end,
			post_checkout = build,
		},
	})

	require('blink.cmp').setup({
		sources = {
			default = { 'lsp', 'path', 'snippets' },
			providers = { path = { opts = { show_hidden_files_by_default = true } } },
		},
		cmdline = { enabled = false },
		completion = {
			documentation = { window = { scrollbar = false } },
			menu = {
				auto_show_delay_ms = 100,
				border = 'none',
				draw = { columns = { { 'kind_icon', 'label', 'kind', gap = 2 } } },
				max_height = 8,
			},
		},
	})
end)

u.now(function()
	add('shellRaining/hlchunk.nvim')

	require('hlchunk').setup({
		indent = { enable = true },
		chunk = {
			enable = true,
			duration = 100,
			delay = 50,
		},
	})
end)

later(function()
	add('junegunn/limelight.vim')
end)

later(function()
	add('shortcuts/no-neck-pain.nvim')

	require('no-neck-pain').setup({
		width = 90,
		buffers = { bo = { signcolumn = 'no' } },
		autocmds = { skipEnteringNoNeckPainBuffer = true },
	})

	vim.keymap.set('n', '<Leader>zz', vim.cmd.NoNeckPain)
end)

later(function()
	add('tpope/vim-surround')
end)

later(function()
	add('bullets-vim/bullets.vim')
end)

later(function()
	add('hakonharnes/img-clip.nvim')

	require('img-clip').setup({
		default = {
			dir_path = function()
				return vim.fn.fnamemodify(u.get_img_dir(), ':.')
			end,
			copy_images = false,
			download_images = false,
			drag_and_drop = { insert_mode = true },
			use_cursor_in_template = false,
			insert_mode_after_paste = false,
		},
	})
end)

now(function()
	add({ source = 'folke/snacks.nvim' })
	require('snacks').setup({
		image = { doc = { max_width = 65, max_height = 40 } },
	})
end)

u.now(function()
	add('OXY2DEV/markview.nvim')

	--- @diagnostic disable
	require('markview').setup({
		preview = { icon_provider = 'devicons' }, -- `mini` missing bg highlight
		yaml = { properties = { data_types = { text = '', number = '' } } },
		markdown = {
			code_blocks = { sign = false },
			headings = {
				shift_width = 0,
				heading_1 = { sign = '', icon = '', hl = '' },
				heading_2 = { sign = '', icon = '', hl = '' },
				heading_3 = { sign = '', icon = '', hl = '' },
				heading_4 = { sign = '', icon = '', hl = '' },
				heading_5 = { sign = '', icon = '', hl = '' },
				heading_6 = { sign = '', icon = '', hl = '' },
			},
		},
		markdown_inline = {
			internal_links = { default = { icon = '' } },
			hyperlinks = { default = { icon = '' } },
			images = { default = { icon = '' } },
			checkboxes = {
				checked = {
					text = '󱍧 ',
					hl = 'DiagnosticOk',
					scope_hl = 'MarkviewCheckboxStriked',
				},
				unchecked = { text = '󱍫 ' },
				['-'] = { text = '󱍩 ', scope_hl = '' },
			},
		},
	})
end)
