" Comment line(s)
nnoremap <leader># I-- <esc>0
vnoremap <leader># o<esc>O{--<esc>gvo<esc>o--}<esc>gvo<esc>0

nnoremap <F9> :ElmMake<CR>
nnoremap <F10> :ElmErrorDetail<CR>

let b:dispatch = 'elm-make %'
let g:elm_format_autosave = 1

set shiftwidth=2
set tabstop=2

