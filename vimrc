"-------------------------------------------------------------------[Vundle]----
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

" Plugin Bundles
Bundle 'bronson/vim-trailing-whitespace'
Bundle 'danchoi/ruby_bashrockets.vim'
Bundle 'edsono/vim-matchit'
Bundle 'ervandew/supertab'
Bundle 'kien/ctrlp.vim'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'Lokaltog/vim-powerline'
Bundle 'majutsushi/tagbar'
Bundle 'mileszs/ack.vim'
" color picker
Bundle 'Rykka/ColorV'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/snipmate-snippets'
Bundle 'scrooloose/syntastic'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-dispatch'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-rvm'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-unimpaired'
Bundle 'vim-scripts/Align'

" Colorscheme Bundles
Bundle 'altercation/vim-colors-solarized'
Bundle 'tomasr/molokai'

" Syntax Bundles
Bundle 'Arduino-syntax-file'
Bundle 'cespare/dtd.vim'
Bundle 'cespare/mxml.vim'
Bundle 'jamestomasino/actionscript-vim-bundle'
Bundle 'jdevera/vim-protobuf-syntax'
Bundle 'juvenn/mustache.vim'
Bundle 'kana/vim-textobj-user'
Bundle 'leshill/vim-json'
Bundle 'nelstrom/vim-textobj-rubyblock'
Bundle 'tclem/vim-arduino'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-markdown'
Bundle 'vim-ruby/vim-ruby'
Bundle 'vim-scripts/Io-programming-language-syntax'
Bundle 'vim-scripts/scala.vim'
Bundle 'vim-scripts/vim-scala'
Bundle 'vim-scripts/yaml.vim'

filetype plugin indent on

"------------------------------------------------------------------[General]----
set secure "locks down the exrc setting
set exrc "enable cwd .vimrc files

set nocompatible
set encoding=utf8
set clipboard=unnamed
set dictionary+=/usr/share/dict/words,~/.vim/dict/words
set fileformats=unix,dos,mac
set pastetoggle=<F5>

syntax on

set nowrap
set nofoldenable

set backspace=indent,eol,start
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set cinoptions=(s,m1,)200,j1,J1

set vb
set t_vb=""

set backup
set swapfile
set backupdir=/tmp
set directory=/tmp
set backupskip=/tmp/*,/private/tmp/*
set errorfile=~/.vim/errors.txt

set lazyredraw

set complete=.,w,k,b,u,t,i
set completeopt=menu

let mapleader=","

"-------------------------------------------------------------------[Layout]----
set number
set laststatus=2
"set ruler
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set listchars=tab:▶━,trail:⌴,extends:▶,precedes:◀

set splitbelow
set splitright

colorscheme molokai

syn on

silent! set colorcolumn=80

function! SyntaxItem()
	return synIDattr(synID(line("."),col("."),1),"name")
endfunction

"--------------------------------------------------------------[Plugins]----
runtime macros/matchit.vim
let g:SuperTabSetDefaultCompletionType="context"
let g:syntastic_javascript_checker="jshint"
let g:fugitive_github_domains = ['git.moneydesktop.com']
" let g:Powerline_symbols='fancy'
let g:Powerline_dividers_override = ['', '', '', '']
call Pl#Theme#RemoveSegment('fileformat')
call Pl#Theme#RemoveSegment('fileencoding')

silent! sign define SyntasticError text=!>
silent! sign define SyntasticWarning text=W>

" NERDTree mappings
nnoremap <leader>ntt :NERDTreeToggle<cr>
nnoremap <leader>ntf :NERDTreeFind<cr>

" Ack.vim mappings
nnoremap <leader>fi :Ack --ruby 
nnoremap <leader>f/ :AckFromSearch --ruby<cr>
nnoremap <leader>fq :cclose<cr>
nnoremap <leader>fo :copen<cr>

" Whitespace mappings
nnoremap <leader>fw :FixWhitespace<cr>

"---------------------------------------------------------------[Search]----
set hlsearch
set incsearch
set smartcase
set ignorecase

"-----------------------------------------------------------[Navigation]----
"set mouse=a
set hidden
set scrolloff=5
set scrolljump=5
set sidescrolloff=5
set sidescroll=1
set wildmenu
set showmatch
set matchtime=2
"set cursorline
"set cursorcolumn

"------------------------------------------------------[Custom Mappings]----

" Tab/Shift-Tab for window movement
nnoremap <silent> <Tab> :wincmd w<cr>
nnoremap <silent> <S-Tab> :wincmd W<cr>

" Disable command mode
nnoremap Q <nop>
" Disable lookups
nnoremap K <nop>

" Disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" Make searching use pcre regexes
nnoremap / /\v
vnoremap / /\v

" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Swap ` and ' usage for moving to marks
nnoremap ' `
nnoremap ` '

" Insert mode delete line
inoremap <c-d> <esc>ddi
" Insert mode uppercase word
inoremap <c-u> <esc>viwUi

" Beginning of line
noremap H ^
" End of line
noremap L $
" Insert line below
noremap <leader>o o<esc>k
" Insert line above
noremap <leader>O O<esc>j
noremap gn :cn<CR>
" Insert line at top of file
noremap gO ggO
" Insert line at bottom of file
noremap go Go
" Visual-select Buffer Contents
noremap <leader>va ggVG
" Copy Buffer Contents
noremap <leader>ya ggVGy
" Copy visually selected lines to System Clipboard
vnoremap <leader>Y !pbcopy<cr>u

" Go to file under cursor
noremap gf :e <cfile><cr>
" Unhighlight search
nnoremap <leader>/ :nohls<cr>
" Edit .vimrc in new vsplit
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
" Source .vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>

" Symbolize word
nnoremap <leader>: viw<esc>bi:<esc>
" Wrap parens around def method args
nnoremap <leader>() ^welr(A)<esc>

" Reformat line
nnoremap <leader>l= V=
" Reformat paragraph
nnoremap <leader>p= vip=

" Block comment visually selected lines
vnoremap <leader># 0<C-V>I# <esc>

" Bundle open equivalent
noremap <leader>bo :Bvsplit 

" Command-mode mispellings
cnoremap Qa qa
cnoremap QA qa
cnoremap Vs vs
cnoremap Sp sp

function! PromoteToLet()
  :normal! dd
  " :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>p :PromoteToLet<cr>

function! WhenIsLunch()
  :normal! !lunch
endfunction
:command! WhenIsLunch :call WhenIsLunch()

"--------------------------------------------------------[Abbreviations]----
" Expand hashrocket
iabbrev hh =>

"---------------------------------------------------------------------------
"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%[Specs/Tests]%%%%
"---------------------------------------------------------------------------
function! RunCurrentTest()
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
  if in_test_file
    call SetTestFile()

    if match(expand('%'), '\.feature$') != -1
      call SetTestRunner("!cucumber")
      exec g:bjo_test_runner g:bjo_test_file
    elseif match(expand('%'), '_spec\.rb$') != -1
      call SetTestRunner("!rspec")
      exec g:bjo_test_runner g:bjo_test_file
    else
      call SetTestRunner("!ruby -Itest")
      exec g:bjo_test_runner g:bjo_test_file
    endif
  else
    exec g:bjo_test_runner g:bjo_test_file
  endif
endfunction

function! SetTestRunner(runner)
  let g:bjo_test_runner=a:runner
endfunction

function! RunCurrentLineInTest()
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
  if in_test_file
    call SetTestFileWithLine()
  end

  exec "!rspec" g:bjo_test_file . ":" . g:bjo_test_file_line
endfunction

function! SetTestFile()
  let g:bjo_test_file=@%
endfunction

function! SetTestFileWithLine()
  let g:bjo_test_file=@%
  let g:bjo_test_file_line=line(".")
endfunction

function! CorrectTestRunner()
  if match(expand('%'), '\.feature$') != -1
    return "cucumber"
  elseif match(expand('%'), '_spec\.rb$') != -1
    return "bx rspec"
  else
    return "bx ruby"
  endif
endfunction

"---------------------------------------------------------------------------

"---------------------------------------------------------------------------
"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%[File Types]%%%%
"---------------------------------------------------------------------------

"-----------------------------------------------------------------[HTML]----
au BufNewFile,BufRead *.htm,*.html set filetype=html.css.javascript

"------------------------------------------------------------------[CSS]----
au BufNewFile,BufRead *.css,*.less set filetype=css

"-----------------------------------------------------------------[HAML]----
au BufNewFile,BufRead *.haml set filetype=haml
au FileType haml set makeprg=haml\ %:p\ %:p:s?haml?html?

"-----------------------------------------------------------------[Ruby]----
au BufNewFile,BufRead *.rb,*.rbw,*.gem,*.gemspec,[rR]akefile,Thorfile,Capfile,*.jbuilder,*.rake,*.thor set filetype=ruby
"au Filetype,BufNewFile *_spec.rb nmap <leader>r :!bundle exec rspec %<cr>
"au Filetype,BufNewFile *_spec.rb nmap <leader>R :exe "!bundle exec rspec %\:" . line(".")<cr>


"---------------------------------------------------------------[Python]----
au FileType python let python_highlight_space_errors=1
au FileType python let python_highlight_all=1
au FileType python set omnifunc=pythoncomplete#Complete

"-------------------------------------------------------------[Markdown]----
au BufNewFile,BufRead *.md,*.mkd,*.markdown set filetype=markdown
au FileType markdown set wrap linebreak

"---------------------------------------------------------[ Processing ]----
au BufNewFile,BufRead *.pde set filetype=java

"-----------------------------------------------------------[ Protobuf ]----
au BufNewFile,BufRead *.proto set filetype=proto

"---------------------------------------------------------------[ YAML ]----
au BufNewFile,BufRead *.yml*,*.yaml*,*.yml.sample* so ~/.vim/bundle/yaml.vim/colors/yaml.vim

"-------------------------------------------------------[ ActionScript ]----
au BufNewFile,BufRead *.as set filetype=io

"---------------------------------------------------------------[ MXML ]----
au BufNewFile,BufRead *.mxml set filetype=mxml

"--------------------------------------------------------------[ Scala ]----
au BufNewFile,BufRead *.scala set filetype=scala
au! Syntax scala source ~/.vim/bundle/scala.vim/syntax/scala.vim

"-----------------------------------------------------------------[ Io ]----
au BufNewFile,BufRead *.io set filetype=io

"------------------------------------------------------------[ Arduino ]----
au BufNewFile,BufRead *.ino,*.pde setlocal filetype=arduino

"---------------------------------------------------------------[ Text ]----
au BufNewFile,BufRead *.txt set filetype=text
au FileType text set wrap linebreak
