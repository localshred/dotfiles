set suffixesadd+=.ex
set suffixesadd+=.exs

let g:ale_fix_on_save = 1

silent! set colorcolumn=100

nnoremap <F9> :Dispatch elixir %<cr>
nnoremap <leader>fi :Ack --elixir -i 
nnoremap <leader>fs :AckFromSearch --elixir<cr>
nnoremap <leader>T :ExTestRunFile<CR>
nnoremap <leader>t :ExTestRunTest<CR>
nnoremap <leader>l :ExTestRunLast<CR>
