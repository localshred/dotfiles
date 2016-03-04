silent! set colorcolumn=100

" Comment line(s)
noremap <leader># I# <esc>
vnoremap <leader># 0<C-V>I# <esc>

" Ack.vim mappings
nnoremap <leader>fi :Ack --elixir -i 
nnoremap <leader>fs :AckFromSearch --elixir<cr>

map <leader>T :ExTestRunFile<CR>
map <leader>t :ExTestRunTest<CR>
map <leader>l :ExTestRunLast<CR>
