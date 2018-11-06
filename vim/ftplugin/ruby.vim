" Bundle open
noremap <leader>bo :Bvsplit 

" Symbolize word
nnoremap <leader>: viw<esc>bi:<esc>

" Wrap parens around def method args
nnoremap <leader>() ^welr(A)<esc>

function! PromoteToLet()
  :normal! dd
  " :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>p :PromoteToLet<cr>

" Ack.vim mappings
nnoremap <leader>fi :Ack --ruby -i 
nnoremap <leader>fs :AckFromSearch --ruby<cr>

nnoremap <leader>copf :!rubocop %<cr>
nnoremap <leader>copa :!rubocop<cr>
