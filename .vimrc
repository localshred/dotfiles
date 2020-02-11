" Must be set before ALE is loaded
let g:ale_completion_enabled = 1

execute pathogen#infect()
syntax on
filetype plugin indent on

let mapleader="\<Space>"

hi default link User1 Error
hi link ALEWarning SpellRare

set autoindent
set background=dark
set backspace=indent,eol,start
set backup
set backupdir=/tmp
set backupskip=/tmp/*,/private/tmp/*
set breakindent
set cinoptions=(s,m1,)200,j1,J1
set clipboard=unnamed
set colorcolumn=100
set complete=.,w,k,b,u,t,i
set completeopt=longest,menuone,preview
set directory=/tmp
set encoding=utf8
set errorfile=~/.vim/errors.txt
set expandtab
set exrc
set fileformats=unix,dos,mac
set foldmethod=manual
set guicursor+=a:blinkon0
set guifont=Fira\ Code:h16
set guioptions=
set hidden
set hlsearch
set ignorecase
set incsearch
set keywordprg=dash
set laststatus=2
set listchars=tab:▶━,trail:⌴,extends:▶,precedes:◀
set matchtime=2
set nocompatible
set nofoldenable
set nojoinspaces
set noshowmode
set nowrap
set number
set pastetoggle=<F5>
set scrolljump=5
set scrolloff=5
set secure
set shell=/bin/zsh
set shiftwidth=2
set showmatch
set sidescroll=1
set sidescrolloff=5
set smartcase
set softtabstop=2
set splitbelow
set splitright
set swapfile
set t_Co=256
set t_md=
set t_ut=
set t_vb=""
set tabstop=2
set termguicolors
set updatetime=2000
set vb
set wildignore=*.o
set wildignore+=*.obj
set wildignore+=*.class
set wildignore+=*/assets/*
set wildignore+=*/cov/*
set wildignore+=*/cover/*
set wildignore+=*/deps/*
set wildignore+=*/doc/*
set wildignore+=*/node_modules/*
set wildignore+=*/priv/static/*
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico
set wildignore+=*.pdf,*.psd
set wildignorecase
set wildmenu

if isdirectory('.git') && executable('git')
  set grepprg=git\ grep\ -nI
endif

if executable('ag') && !isdirectory('.git')
  " Silver searcher instead of grep
  set grepprg=ag\ --vimgre\ -p\ ~/.ignore
  set grepformat=%f:%l:%c%m
endif

colorscheme one " molokai nova tender one(bg dark)

let g:ackprg='ag --vimgrep -p ~/.ignore'
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
let g:airline#extensions#ale#enabled = 1
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
let g:ale_elixir_elixir_ls_release = '/code/src/utilities/elixir-ls/rel'
let g:ale_fixers = {}
let g:ale_fixers.css = ['prettier-standard']
let g:ale_fixers.elixir = ['mix_format']
let g:ale_fixers.elm = ['elm-format']
let g:ale_fixers.flow = ['prettier-standard']
let g:ale_fixers.go = ['gofmt']
let g:ale_fixers.graphql = ['prettier-standard']
let g:ale_fixers.java = ['prettier-standard']
let g:ale_fixers.javascript = ['prettier-standard']
let g:ale_fixers.json = ['prettier-standard']
let g:ale_fixers.jsx = ['prettier-standard']
let g:ale_fixers.less = ['prettier-standard']
let g:ale_fixers.markdown = ['prettier-standard']
let g:ale_fixers.sql = ['prettier-standard']
let g:ale_fixers.php = ['prettier-standard']
let g:ale_fixers.python = ['prettier-standard']
let g:ale_fixers.ruby = ['prettier-standard']
let g:ale_fixers.scss = ['prettier-standard']
let g:ale_fixers.swift = ['prettier-standard']
let g:ale_fixers.typescript = ['prettier-standard']
let g:ale_fixers.vue = ['prettier-standard']
let g:ale_fixers.yaml = ['prettier-standard']
let g:ale_fix_on_save = 1
let g:ale_lint_on_enter = 1
let g:ale_linters = {}
let g:ale_linters.javascript = ['standard']
let g:ale_linters.elixir = ['elixir-ls', 'credo']
let g:ale_linters.clojure = ['clj-kondo']
let g:clang_close_preview = 1
let g:clang_complete_auto = 0
let g:clang_exec = '/usr/bin/clang'
let g:clang_library_path = '/usr/local/lib/libclang.dylib'
let g:clang_periodic_quickfix = 0
let g:clang_snippets = 1
let g:clang_snippets_engine = 'ultisnips'
let g:clang_use_library = 1
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_user_command = 'ag %s -l --nocolor -g "" -p ~/.ignore'
let g:dash_activate = 0
let g:jsx_ext_required = 0
let g:localvimrc_whitelist='/code/src/\(crux\|localshred\|mmoney\|utilities\|go/gitlab.com/mmoney\)/.*'
let g:localvimrc_persistent=2
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
" let g:python_host_prog = '/Users/bj/.pyenv/versions/neovim2/bin/python'
" let g:python3_host_prog = '/Users/bj/.pyenv/versions/neovim3/bin/python'
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
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
let g:tagbar_type_typescript = {
  \ 'ctagstype' : 'typescript',
  \ 'kinds'     : [
    \ 'c:classes',
    \ 'a:abstract classes',
    \ 't:types',
    \ 'n:modules',
    \ 'f:functions',
    \ 'v:variables',
    \ 'l:varlambdas',
    \ 'm:members',
    \ 'i:interfaces',
    \ 'e:enums'
  \ ],
  \ 'sro'        : '.',
  \ 'kind2scope' : {
    \ 'c' : 'classes',
    \ 'a' : 'abstract classes',
    \ 't' : 'types',
    \ 'f' : 'functions',
    \ 'v' : 'variables',
    \ 'l' : 'varlambdas',
    \ 'm' : 'members',
    \ 'i' : 'interfaces',
    \ 'e' : 'enums'
  \ },
  \ 'scope2kind' : {
    \ 'classes'    : 'c',
    \ 'abstract classes'    : 'a',
    \ 'types'      : 't',
    \ 'functions'  : 'f',
    \ 'variables'  : 'v',
    \ 'varlambdas' : 'l',
    \ 'members'    : 'm',
    \ 'interfaces' : 'i',
    \ 'enums'      : 'e'
  \ }
  \ }
let test#filename_modifier = ":p"
let test#strategy = 'neovim'

cnoremap Q q
cnoremap Qa qa
cnoremap QA qa
cnoremap Sp sp
cnoremap Tabnew tabnew
cnoremap TAbnew tabnew
cnoremap Vs vs
cnoremap Wa wa
cnoremap WA wa
cnoremap Wq wq
cnoremap WQ wq
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
nnoremap <c-j> :ALENextWrap<cr>
nnoremap <c-k> :ALEPreviousWrap<cr>
nnoremap <F9> :Dispatch<cr>
nnoremap <leader>/ :nohls<cr>
nnoremap <leader>al :Align 
nnoremap <leader>cn :cnext<cr>
nnoremap <leader>cp :cprevious<cr>
nnoremap <leader>d :ALEDetail<cr>
nnoremap <leader>ev :vsplit ~/.vimrc<cr>
nnoremap <leader>fi :Ack! -i 
nnoremap <leader>fn :NERDTreeFind<cr>j<cr>
nnoremap <leader>fp :NERDTreeFind<cr>k<cr>
nnoremap <leader>fq :cclose<cr>
nnoremap <leader>fs :AckFromSearch!<cr>
nnoremap <leader>ft :tselect /
nnoremap <leader>fw :FixWhitespace<cr>
nnoremap <leader>gdd :vs<cr>:ALEGoToDefinition<cr>
nnoremap <leader>gds :vs<cr>:ALEGoToDefinition<cr>
nnoremap <leader>gdt :vs<cr>:ALEGoToDefinitionInTab<cr>
nnoremap <leader>k :ALEHover<cr>
nnoremap <leader>ntf :NERDTreeFind<cr>
nnoremap <leader>ntt :NERDTreeToggle<cr>
nnoremap <leader>pb :CtrlPBuffer<cr>
nnoremap <leader>pd :CtrlPDir<cr>
nnoremap <leader>pf :CtrlP<cr>
nnoremap <leader>pm :CtrlPMRU<cr>
nnoremap <leader>pt :CtrlPTag<cr>
nnoremap <leader>sv :source ~/.vimrc<cr>
nnoremap <leader>tb :TagbarToggle<cr>
nnoremap <leader>tc :tabclose<cr>
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>ts :tab split<cr>
nnoremap <leader>w <c-w>
nnoremap <leader>{s vi{S  
nnoremap <silent> <s-tab> :wincmd W<cr>
nnoremap <silent> <tab> :wincmd w<cr>
nnoremap gd [<c-i>
nnoremap gdvs :vs<cr>gd
nnoremap P [P
nnoremap p ]p
nnoremap Q <nop>
noremap <leader>O O<esc>j
noremap <leader>o o<esc>k
noremap <leader>va ggVG
noremap <leader>ya ggVGy
noremap gn :cn<cr>
noremap gp :cp<cr>
noremap H ^
noremap L $
vnoremap / /\v
vnoremap <leader>S :sort i<cr>
nnoremap <leader>nofixsave let g:ale_fix_on_save=0<cr>
nnoremap <leader>fixsave let g:ale_fix_on_save=1<cr>

" Filetype mappings that need some help
autocmd BufNewFile,BufRead Makefile setlocal noexpandtab
autocmd BufNewFile,BufRead *.es6,*.jsx setlocal filetype=javascript
autocmd BufNewFile,BufRead *.io set filetype=io
autocmd BufNewFile,BufRead *.y{,a}ml.sample set ft=yaml
autocmd BufNewFile,BufRead *.apib set ft=markdown
autocmd BufNewFile,BufRead .env{,.sample} set ft=bash
