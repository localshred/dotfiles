" Comment line(s)
nnoremap <leader># I-- <esc>0
vnoremap <leader># o<esc>O{--<esc>gvo<esc>o--}<esc>gvo<esc>0
nnoremap <F9> :ElmMake<CR>
let b:dispatch = 'elm-make %'
