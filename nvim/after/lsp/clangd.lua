return {
	filetypes = { 'c', 'cpp' },
	cmd = { 'clangd', '--background-index' },
	root_markers = { 'compile_commands.json', 'compile_flags.txt' },
}
