set suffixesadd+=.js

let g:ale_fix_on_save = 1

" Wrap one-liner if/else in braces
nnoremap <leader>{} o{<esc>jo}<esc>3k

" Ack.vim mappings
nnoremap <leader>fi :Ack --js -i 
nnoremap <leader>fs :AckFromSearch --js<cr>
nnoremap <leader>gd :vs<cr>gd$hhgf
