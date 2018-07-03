execute pathogen#infect()
syntax on
filetype plugin indent on

let mapleader="\<Space>"

set autoindent
set background=dark
set backspace=indent,eol,start
set backup
set backupdir=/tmp
set backupskip=/tmp/*,/private/tmp/*
set breakindent
set cinoptions=(s,m1,)200,j1,J1
set clipboard=unnamed
set complete=.,w,k,b,u,t,i
set completeopt=longest,menuone,preview
set cursorline
set directory=/tmp
set encoding=utf8
set errorfile=~/.vim/errors.txt
set expandtab
set exrc "enable cwd .vimrc files
set fileformats=unix,dos,mac
set foldmethod=syntax
set grepprg=ack\ -k
set hidden
set hlsearch
set ignorecase
set incsearch
set keywordprg=dash
set laststatus=2
set lazyredraw
set listchars=tab:▶━,trail:⌴,extends:▶,precedes:◀
set matchtime=2
set nocompatible
set nofoldenable
set noshowmode
set nowrap
set number
set pastetoggle=<F5>
set scrolljump=5
set scrolloff=5
set secure "locks down the exrc setting
set shell=/bin/bash
set shiftwidth=2
set showmatch
set sidescroll=1
set sidescrolloff=5
set smartcase
set softtabstop=2
set splitbelow
set splitright
hi default link User1 Error
set swapfile
set t_Co=256
set t_ut=
set t_vb=""
set tabstop=2
set termguicolors
set vb
set wildmenu

colorscheme one " molokai nova tender one(bg dark)

silent! set colorcolumn=100
silent! sign define SyntasticError text=!>
silent! sign define SyntasticWarning text=W>

let g:ackprg='ag --nogroup --nocolor --column'
let g:airline_left_sep=''
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'L',
    \ '' : 'B',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ }
let g:airline_right_sep=''
let g:airline_theme='one' " bubblegum raven lucius tender one
let g:airline_section_y=''
let g:airline_section_z=''
let g:airline_section_error='%{ALEGetStatusLine()}'
let g:airline#extensions#branch#empty_message='[no branch]'
let g:airline#extensions#branch#format=2 " truncate all paths but final in branch name
let g:airline#extensions#syntastic#enabled=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_buffers=0
let g:airline#extensions#tabline#show_close_button=0
let g:airline#extensions#tabline#show_splits=0
let g:airline#extensions#tabline#show_tab_nr=0
let g:airline#extensions#tabline#tab_min_count=2
let g:airline#extensions#tagbar#flags='f'
let g:ale_sign_error = '💥'
let g:ale_sign_warning = '⚠️'
let g:clang_close_preview = 1
let g:clang_complete_auto = 0
let g:clang_exec = '/usr/bin/clang'
let g:clang_library_path = '/usr/local/lib/libclang.dylib'
let g:clang_periodic_quickfix = 0
let g:clang_snippets = 1
let g:clang_snippets_engine = 'ultisnips'
let g:clang_use_library = 1
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)$|node_modules/|coverage/)',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
  \ }
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
let g:elm_format_autosave=1
let g:jsx_ext_required = 0
let g:localvimrc_whitelist='/code/src/\(services\|gems\|utilities\|modules|apps\)/.*'
let g:localvimrc_persistent=2
" let g:mix_format_on_save = 1
let g:mix_format_elixir_bin_path = '/code/src/languages/elixir/bin'
let g:projectionist_heuristics = {
      \ "src/*.js": {
      \   "alternate": "test/unit/app/{}.test.js",
      \   "type": "src",
      \   "template": [
      \     "const R = require('ramda'",
      \     "",
      \     "const {} = () => {}",
      \     "",
      \     "module.exports = {}",
      \   ]
      \ },
      \ 
      \ "test/unit/src/*.test.js": {
      \   "type": "test",
      \   "alternate": "{}.js",
      \   "make": "./node_modules/.bin/jest --no-color {file}",
      \   "dispatch": "./node_modules/.bin/jest --no-color {file}",
      \   "template": [
      \     "/* eslint-env jest */",
      \     "",
      \     "const {basename|camelcase} = require('{}')",
      \     "",
      \     "describe('{}', () => {",
      \     "  describe('default', () => {",
      \     "    it('does a thing', () => {",
      \     "      expect('You should add a test here').toBe('please')",
      \     "    })",
      \     "  })",
      \     "})"
      \   ]
      \ }
      \}
let g:rainbow_active = 1
let g:SuperTabSetDefaultCompletionType="context"
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_cs_checkers=["syntax","issues"]
let g:tagbar_ctags_bin = '/usr/local/bin/ctags'
let g:tagbar_sort = 1
let g:tagbar_type_elixir = {
    \ 'ctagstype' : 'elixir',
    \ 'kinds' : [
        \ 'f:functions',
        \ 'functions:functions',
        \ 'c:callbacks',
        \ 'd:delegates',
        \ 'e:exceptions',
        \ 'i:implementations',
        \ 'a:macros',
        \ 'o:operators',
        \ 'm:modules',
        \ 'p:protocols',
        \ 'r:records',
        \ 't:tests'
    \ ]
\ }
let test#strategy = 'dispatch'

highlight clear ALEErrorSign
highlight clear ALEWarningSign

cnoremap Qa qa
cnoremap QA qa
cnoremap Q q
cnoremap Sp sp
cnoremap Vs vs
cnoremap Wa wa
cnoremap WA wa
cnoremap Wq wq
cnoremap WQ wq
cnoremap Tabnew tabnew
cnoremap TAbnew tabnew
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
imap <up> <nop>
inoremap <c-d> <esc>ddi
inoremap <c-u> <esc>viwUeai
map <down> <nop>
map <left> <nop>
map <right> <nop>
map <up> <nop>
nnoremap / /\v
nnoremap <F9> :Dispatch<cr>
nnoremap <leader>/ :nohls<cr>
nnoremap <leader>al :Align 
nnoremap <leader>cn :cnext<cr>
nnoremap <leader>cp :cprevious<cr>
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>fi :Ack -i 
nnoremap <leader>fq :cclose<cr>
nnoremap <leader>fs :AckFromSearch<cr>
nnoremap <leader>fw :FixWhitespace<cr>
nnoremap <leader>ntf :NERDTreeFind<cr>
nnoremap <leader>ntt :NERDTreeToggle<cr>
nnoremap <leader>pb :CtrlPBuffer<cr>
nnoremap <leader>pd :CtrlPDir<cr>
nnoremap <leader>pf :CtrlP<cr>
nnoremap <leader>pm :CtrlPMRU<cr>
nnoremap <leader>pt :CtrlPTag<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>ts :tab split<cr>
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>tc :tabclose<cr>
nnoremap <leader>w <c-w>
nnoremap <leader>{s vi{S  
nnoremap <silent> <s-tab> :wincmd W<cr>
nnoremap <silent> <tab> :wincmd w<cr>
nnoremap gd [<c-i>
nnoremap P [P
nnoremap p ]p
nnoremap Q <nop>
noremap <leader>O O<esc>j
noremap <leader>o o<esc>k
noremap <leader>va ggVG
noremap <leader>ya ggVGy
noremap gn :cn<cr>
noremap gO ggO<esc><c-o>
noremap go Go
noremap H ^
noremap L $
vnoremap / /\v
vnoremap <leader>al :Align 
vnoremap <leader>S :sort i<cr>

" Filetype mappings that need some help
au BufNewFile,BufRead *.es6,*.jsx setlocal filetype=javascript
au BufNewFile,BufRead *.glsl setlocal filetype=glsl
au BufNewFile,BufRead *.io set filetype=io
au BufNewFile,BufRead *.scala set filetype=scala
au BufNewFile,BufRead *.y{,a}ml.sample set ft=yaml
au BufNewFile,BufRead *.apib set ft=markdown
au BufNewFile,BufRead *.icss set ft=css
" au FileType javascript set formatprg=prettier-standard
" au BufWritePre *.js :normal mtgggqG't
