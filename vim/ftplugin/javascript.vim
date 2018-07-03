set suffixesadd+=.js

let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier-standard']
let g:ale_fix_on_save = 1

" Comment line(s)
noremap <leader># I// <esc>
vnoremap <leader># 0<C-V>I// <esc>

" Wrap one-liner if/else in braces
nnoremap <leader>{} o{<esc>jo}<esc>3k

" Ack.vim mappings
nnoremap <leader>fi :Ack --js -i 
nnoremap <leader>fs :AckFromSearch --js<cr>
