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
set laststatus=2
set lazyredraw
set listchars=tab:▶━,trail:⌴,extends:▶,precedes:◀
set matchtime=2
set nocompatible
set nofoldenable
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
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set swapfile
set t_vb=""
set tabstop=2
set vb
set wildmenu

colorscheme spacegray

silent! set colorcolumn=80
silent! sign define SyntasticError text=!>
silent! sign define SyntasticWarning text=W>

let g:ackprg='ag --nogroup --nocolor --column'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_buffers=0
let g:airline#extensions#tabline#show_close_button=0
let g:airline#extensions#tabline#tab_min_count=2
let g:airline#extensions#tagbar#flags='f'
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_theme='bubblegum' " raven lucius
let g:clang_close_preview = 1
let g:clang_complete_auto = 0
let g:clang_exec = '/usr/bin/clang'
let g:clang_library_path = '/usr/local/lib/libclang.dylib'
let g:clang_periodic_quickfix = 0
let g:clang_snippets = 1
let g:clang_snippets_engine = 'ultisnips'
let g:clang_use_library = 1
let g:ctrlp_custom_ignore = {
      \ 'dir': '\v(node_modules/|tmp/|elm-stuff/)',
      \ 'file': '\v\.(beam|o)$',
      \ }
let g:jsx_ext_required = 0
let g:localvimrc_whitelist='/code/src/\(services\|gems\|utilities\)/.*'
let g:rubytest_in_quickfix = 0
let g:SuperTabSetDefaultCompletionType="context"
let g:syntastic_cs_checkers=["syntax","issues"]
" let g:tagbar_ctags_bin = '/usr/local/bin/ctags'
" let g:tagbar_type_elixir = {
"     \ 'ctagstype' : 'elixir',
"     \ 'kinds' : [
"         \ 'f:functions',
"         \ 'functions:functions',
"         \ 'c:callbacks',
"         \ 'd:delegates',
"         \ 'e:exceptions',
"         \ 'i:implementations',
"         \ 'a:macros',
"         \ 'o:operators',
"         \ 'm:modules',
"         \ 'p:protocols',
"         \ 'r:records'
"     \ ]
" \ }

cnoremap Q q
nnoremap <F9> :Dispatch<CR>
nnoremap <leader>al :Align 
nnoremap <leader>cn :cnext<cr>
nnoremap <leader>cp :cprevious<cr>
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
vnoremap <leader>al :Align 

nnoremap <silent> <Tab> :wincmd w<cr>
nnoremap <silent> <S-Tab> :wincmd W<cr>
nnoremap <leader>w <c-w>

nnoremap Q <nop>

vnoremap <leader>S :sort i<cr>

map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

nnoremap / /\v
vnoremap / /\v

" Insert mode delete line
inoremap <c-d> <esc>ddi
" Insert mode uppercase word
inoremap <c-u> <esc>viwUeai

" Beginning of line
noremap H ^
" End of line
noremap L $
" Insert line below
noremap <leader>o o<esc>k
" Insert line above
noremap <leader>O O<esc>j
" Go to next match in quickfix window
noremap gn :cn<CR>
" Insert line at top of file
noremap gO ggO<esc><c-o>
" Insert line at bottom of file
noremap go Go
" Visual-select Buffer Contents
noremap <leader>va ggVG
" Copy Buffer Contents
noremap <leader>ya ggVGy

" Unhighlight search
nnoremap <leader>/ :nohls<cr>
" Edit .vimrc in new vsplit
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
" Source .vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>

" Tabs
nnoremap <leader>ts :tab split<cr>

" Command-mode mispellings
cnoremap Qa qa
cnoremap QA qa
cnoremap Wa wa
cnoremap WA wa
cnoremap Wq wq
cnoremap WQ wq
cnoremap Vs vs
cnoremap Sp sp

" Filetype mappings that need some help
au BufNewFile,BufRead *.es6 setlocal filetype=javascript.jsx
au BufNewFile,BufRead *.glsl setlocal filetype=glsl
au BufNewFile,BufRead *.io set filetype=io
au BufNewFile,BufRead *.scala set filetype=scala
au BufNewFile,BufRead *.y{,a}ml.sample set ft=yaml

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

