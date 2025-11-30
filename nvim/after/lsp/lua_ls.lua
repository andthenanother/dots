return {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	single_file_support = true,
	root_markers = {
		'.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml',
		'stylua.toml', 'selene.toml', 'selene.yml', '.git',
	},
	settings = {
		Lua = {
			completion = {
				callSnippet = 'Disable',
				keywordSnippet = 'Disable',
			},
			diagnostics = {
				disable = {
					'unused-function',
					'trailing-space',
				},
			},
			workspace = {
				ignoreSubmodules = true,
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
}
