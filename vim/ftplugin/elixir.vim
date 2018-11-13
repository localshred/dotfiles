set suffixesadd+=.ex
set suffixesadd+=.exs

let g:ale_fix_on_save = 1

silent! set colorcolumn=100

nnoremap <F9> :Dispatch mix credo suggest --format=flycheck %<cr>
nnoremap <leader>fi :Ack --elixir -i 
nnoremap <leader>fs :AckFromSearch --elixir<cr>
nnoremap <leader>T :ExTestRunFile<cr>
nnoremap <leader>t :ExTestRunTest<cr>
nnoremap <leader>l :ExTestRunLast<cr>
nnoremap <leader>gd :ALEGoToDefinitionInTab<cr>

" Pipe extract case A (more than one arg in parens)
nnoremap <leader>pa 0f(ldt,O<esc>po\|><esc>Jf,xxVk=

" Pipe extract case B (one arg in parens)
nnoremap <leader>pb 0f(di(ko<esc>pjI\|> <esc>Vk=
