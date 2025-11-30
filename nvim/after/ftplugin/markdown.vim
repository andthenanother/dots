nnoremap <buffer> <silent> <CR> :lua require("helpers").enter_link()<CR>
nnoremap <buffer> <silent> ZI :lua require("helpers").image_delete()<CR>
nnoremap <buffer> <silent> <M-v> :lua require("img-clip").paste_image({ copy_images = true, download_images = true }) vim.cmd("silent! update")<CR>

setl foldtext=
setl foldexpr=luaeval('vim.treesitter.foldexpr()')
setl foldmethod=expr
setl foldlevel=99
setl nonumber
setl norelativenumber
setl signcolumn=no
setl smoothscroll
setl wrap
