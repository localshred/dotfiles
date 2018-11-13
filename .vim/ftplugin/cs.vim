set tabstop=4
set softtabstop=4
set shiftwidth=4
setlocal omnifunc=OmniSharp#Complete

" Wrap one-liner if/else in braces
nnoremap <leader>{} o{<esc>jo}<esc>3k

" Ack.vim mappings
nnoremap <leader>fl :Ack --csharp -i 
nnoremap <leader>fs :AckFromSearch --csharp<cr>

