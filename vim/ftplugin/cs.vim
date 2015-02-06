set tabstop=4
set softtabstop=4
set shiftwidth=4
setlocal omnifunc=OmniSharp#Complete

au BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck

" Comment line(s)
noremap <leader># I// <esc>
vnoremap <leader># 0<C-V>I// <esc>

" Wrap one-liner if/else in braces
nnoremap <leader>{} o{<esc>jo}<esc>3k

" Ack.vim mappings
nnoremap <leader>fl :Ack --csharp -i 
nnoremap <leader>fs :AckFromSearch --csharp<cr>

