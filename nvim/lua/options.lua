local api = vim.api
local fn = vim.fn
local later = MiniDeps.later

vim.g.mapleader = ' '

vim.o.undodir = fn.stdpath('cache') .. '/undo'
vim.o.undofile = true
vim.o.undolevels = 500
vim.o.shada = "'100,<50,s10,:1000,/100,@100,h"

vim.o.virtualedit = 'block'
vim.o.switchbuf = 'usetab'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.jumpoptions = 'stack'
vim.o.formatoptions = 'rqnl1j'
vim.o.shortmess = 'CFcsIa'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'
vim.o.tabstop = 2
vim.o.shiftwidth = 0
vim.o.copyindent = true
vim.o.shiftround = true
vim.o.spelloptions = 'camel'
vim.o.spellsuggest = 'best,10'

vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 1
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.wrap = false
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.winborder = 'rounded'
vim.o.cmdheight = 0
vim.o.ruler = false
vim.o.showcmd = false
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.fillchars = table.concat({
	'eob: ',
	'lastline: ',
}, ',')

vim.o.guicursor = 'i-c-ci:ver25-blinkon400-blinkoff400'

-- Use `later()` to avoid sourcing `vim.lsp` and `vim.diagnostic` on startup
later(function()
	if fn.has('nvim-0.11') ~= 1 then
		return
	end

	vim.lsp.log.set_level('off')

	vim.diagnostic.config({
		underline = { severity = vim.diagnostic.severity.HINT },
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = '󰅚 ',
				[vim.diagnostic.severity.WARN] = '󰀪 ',
				[vim.diagnostic.severity.INFO] = '󰋽 ',
				[vim.diagnostic.severity.HINT] = '󰌶 ',
			},
		},
		virtual_lines = { current_line = true },
	})

	local hover = vim.lsp.buf.hover
	vim.lsp.buf.hover = function() ---@diagnostic disable-line: duplicate-set-field
		return hover({
			max_height = math.floor(vim.o.lines * 0.5),
			max_width = math.floor(vim.o.columns * 0.4),
		})
	end

	local server_configs = vim.iter(api.nvim_get_runtime_file('lsp/*.lua', true))
		:map(function(file) return fn.fnamemodify(file, ':t:r') end)
		:totable()
	vim.lsp.enable(server_configs)
end)
