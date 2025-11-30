vim.loader.enable(true)

vim.go.loadplugins = false
vim.cmd.runtime('plugin/man.lua')

local path = vim.fn.stdpath('data') .. '/site/pack/deps/start/mini.deps'
if not vim.uv.fs_stat(path) then
	vim.cmd('echo "Installing `mini.deps`" | redraw')
	local clone = {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/nvim-mini/mini.deps',
		path,
	}
	vim.fn.system(clone)
	vim.cmd('packadd mini.deps | helptags ALL')
	vim.cmd('echo "Installed `mini.deps`" | redraw')
end

require('mini.deps').setup({
	path = { snapshot = vim.fn.stdpath('config') .. '/../mini-deps-snap' },
})

vim.cmd.colorscheme('lotus')

require('options')
require('au')
require('spec')
require('ui')
require('keymap')
