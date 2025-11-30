local u = require('helpers')

vim.keymap.set('x', '/', '<Esc>/\\%V', { silent = false }) -- Search in visual region
vim.keymap.set('n', "'", '`') -- Jump to mark position (row, col), not line

vim.keymap.set('n', '<M-a>', '<Cmd>arga<CR>')

for arg = 1, 9 do
	vim.keymap.set('n', '<M-' .. arg .. '>', '<CMD>argu ' .. arg .. '<CR>')
	vim.keymap.set('n', '<Leader>' .. arg, '<CMD>' .. arg - 1 .. 'arga<CR>')
	vim.keymap.set('n', '<Leader>d' .. arg, '<CMD>' .. arg .. 'argd<CR>')
end

vim.keymap.set('n', '<CR>', function()
	local link = vim.api.nvim_get_current_line():find('%b[]%b()')

	if not link then
		return vim.api.nvim_feedkeys(vim.keycode('<CR>'), 'n', false)
	end

	vim.lsp.buf.definition()
end)

vim.keymap.set('n', 'ZB', u.bufremove)

vim.keymap.set('n', 'dm', function()
	local mark = vim.fn.getcharstr()
	if mark:match('%u') then
		return vim.api.nvim_del_mark(mark)
	end
	vim.api.nvim_buf_del_mark(0, mark)
end)

-- Respect wrap
-- Add jumps >=5 to jumplist
vim.keymap.set({ 'n', 'x' }, 'j', "(v:count >= 5 ? 'm`' . v:count : 'g') . 'j'", { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', "(v:count >= 5 ? 'm`' . v:count : 'g') . 'k'", { expr = true })

vim.keymap.set('i', '<C-l>', '<C-g>u<ESC>[s1z=`]a<C-g>u') -- Fix last spelling error

vim.keymap.set('n', '<Leader>zl', function()
	vim.cmd('Limelight!!')
end)

-- Keep visual region when indenting
vim.keymap.set('x', '<', '<gv', { silent = true })
vim.keymap.set('x', '>', '>gv', { silent = true })

vim.keymap.set('n', 'siw', ':%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>') -- Substitute current word
vim.keymap.set('n', 'sip', ":'{,'}s/\\<<C-r><C-w>\\>//g<Left><Left>") -- Substitute in paragraph
vim.keymap.set('x', 's', 'y:%s/<C-r><C-0>//g<Left><Left>') -- Substitute highlighted region
