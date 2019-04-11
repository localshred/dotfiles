let g:ale_fix_on_save = 1
let g:go_bin_path = "/code/src/go-workspace/bin"

nnoremap <F9> :GoBuild<cr>
nnoremap <leader>fi :Ack --go -i 
nnoremap <leader>fs :AckFromSearch --go<cr>
nnoremap <leader>T :GoTest<cr>
nnoremap <leader>t :GoTestFunc<cr>
nnoremap <leader>gcov :GoCoverage<cr>
nnoremap <leader>gcovc :GoCoverageClear<cr>
nnoremap <leader>gr :GoRename 

