"------------------------------------------------------------------[General]----
set nocompatible
set encoding=utf8

filetype on
filetype indent on
filetype plugin on

set backspace=2
set tabstop=2
set shiftwidth=2
set softtabstop=2
set nowrap
set nofoldenable
set autoindent

set vb
set t_vb=""

set backup
set swapfile
set backupdir=~/.vim/backup
set directory=~/.vim/swp

set lazyredraw

set complete=.,w,k,b,u,t,i
set completeopt=menu

"-------------------------------------------------------------------[Layout]----
set number
set laststatus=2
set ruler
set listchars=tab:\|\ ,trail:▪,extends:▶,precedes:◀
set list
set pumheight=5

if has("builtin_gui")
	colorscheme paintbox
elseif (&term == "xterm-256color")
	colorscheme busybee
else
	set background=light
	colorscheme solarized
endif

syn on

autocmd BufEnter * highlight OverLength ctermfg=white guibg=#323222
autocmd BufEnter * match OverLength /\%81v.\+/

"-------------------------------------------------------------------[Search]----
set hlsearch
set incsearch
set smartcase
set ignorecase

"---------------------------------------------------------------[Navigation]----
set mouse=a
set hidden
set scrolloff=5
set scrolljump=5
set sidescrolloff=10
set sidescroll=1
set wildmenu

nnoremap <silent> <Tab> :wincmd w<CR>
nnoremap <silent> <S-Tab> :wincmd W<CR>

map j gj
map k gk

"-------------------------------------------------------------------------------
"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%[File Types]%%%%
"-------------------------------------------------------------------------------


"---------------------------------------------------------------------[HTML]----
autocmd BufNewFile,BufRead *.htm,*.html set filetype=html

"----------------------------------------------------------------------[CSS]----

"---------------------------------------------------------------------[YAML]----

"---------------------------------------------------------------------[HAML]----
"make -> haml infile.haml outfile.html
autocmd BufNewFile,BufRead *.haml set filetype=haml
autocmd FileType haml set noexpandtab
autocmd FileType haml set shiftwidth=4 tabstop=4 softtabstop=4

"---------------------------------------------------------------------[SASS]----
"make -> sass infile.sass outfile.css
autocmd BufNewFile,BufRead *.sass set filetype=sass
autocmd FileType sass set noexpandtab
autocmd FileType sass set shiftwidth=4 tabstop=4 softtabstop=4

"---------------------------------------------------------------[JavaScript]----
autocmd BufNewFile,BufRead *.js set filetype=javascript
autocmd FileType javascript set shiftwidth=4 tabstop=4 softtabstop=4

"---------------------------------------------------------------------[Ruby]----
"make -> ruby -c
autocmd BufNewFile,BufRead *.rb,*.rbw,*.gem,*.gemspec,[rR]akefile,*.rake,*.thor,Capfile set filetype=ruby
autocmd FileType ruby set expandtab
autocmd FileType ruby set shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType ruby set dictionary=$HOME/.vim/dict/ruby.dict
autocmd FileType ruby set omnifunc=rubycomplete#Complete

"-------------------------------------------------------------[ActionScript]----
autocmd BufNewFile,BufRead *.as set filetype=actionscript
"autocmd FileType actionscript set omnifunc=actionscriptcomplete#Complete
"autocmd FileType actionscript set complete=k$HOME/.vim/dict/actionscript.dict,.,w,b,u,t,i
autocmd FileType actionscript set makeprg=as3compile\ %:p\ -X\ 320\ -Y\ 240\ -o\ %:p:s?as?swf?

"---------------------------------------------------------------------[haXe]----
autocmd BufNewFile,BufRead *.hx set filetype=haxe

"-------------------------------------------------------------------[Python]----
autocmd BufNewFile,BufRead *.py set filetype=python
autocmd FileType python set expandtab
autocmd FileType python set shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType python let python_highlight_space_errors=1
autocmd FileType python let python_highlight_all=1
autocmd FileType python set omnifunc=pythoncomplete#Complete

"------------------------------------------------------------------------[C]----

"--------------------------------------------------------------------[Obj-C]----

"-----------------------------------------------------------------[Markdown]----
autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown set filetype=mkd
