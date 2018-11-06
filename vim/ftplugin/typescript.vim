set suffixesadd+=.ts
set suffixesadd+=.tsx

let g:ale_fix_on_save = 1

" Ack.vim mappings
nnoremap <leader>fi :Ack --typescript -i 
nnoremap <leader>fs :AckFromSearch --typescript<cr>
nnoremap <leader>tss :TSSstarthere<cr>
nnoremap <buffer> <C-w>} :TSSdeftab<cr>

autocmd BufNewFile,BufRead call TSSkeymap()

if !exists("g:ycm_semantic_triggers")
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']
