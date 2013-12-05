" Make Vim more useful
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=","
let maplocalleader = "\\"
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif

" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" Make tabs as wide as two spaces
set tabstop=2
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,nbsp:_
set list
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Enable mouse in all modes
set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Start scrolling three lines before the horizontal window border
set scrolloff=3

" Strip trailing whitespace (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
endif

"""""""""""""""
" Vundle config

filetype off                  " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

" My bundles here:
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'YankRing.vim'
Bundle 'godlygeek/tabular'
Bundle 'bling/vim-airline'
Bundle 'mileszs/ack.vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/nerdtree'
Bundle 'kien/ctrlp.vim'

" for Clojure
Bundle 'tpope/vim-fireplace'
Bundle 'paredit.vim'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'tpope/vim-classpath'

" End of my bundles

filetype plugin indent on     " required!

" End of Vundle config
""""""""""""""""""""""

" NERDTree settings
let NERDTreeIgnore=['^classes[[dir]]', '^target[[dir]]', '\.class$', '\.pyc$', '\.pyo$', '\.rbc$', '\.rbo$', '\.class$', '\.o$', '\~$']
map <Leader>n :NERDTreeToggle<CR> :NERDTreeMirror<CR>

" CtrlP ignore
set wildignore+=*.class

" bind Fugitive functions
nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gp :Git push<CR>

nmap <Leader>q :nohlsearch<CR>
nmap <silent><C-e> :e#<CR>

" Clear trailing whitespaces and multiple blank lines
map <Leader>fm :%s/\s\+$//<BAR>g/^\s*$/,/\S/-j<BAR>noh<CR>

nnoremap <silent><C-J> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><C-K> :set paste<CR>m`O<Esc>``:set nopaste<CR>
nnoremap <silent> <F11> :YRShow<CR>
nnoremap <C-k> O<Esc>j
nnoremap <C-j> o<Esc>k

" bind :Ack to Cmd-F
nnoremap <D-F> :Ack<space>

let g:paredit_electric_return = 0
let g:clojure_align_multiline_strings = 1
let g:clojure_maxlines = 1000
autocmd FileType clojure setlocal lispwords+=facts,fact
autocmd FileType clojure nnoremap <localleader>rt :Require!<Bar>Eval (clojure.test/run-tests)<CR>
autocmd FileType clojure nnoremap <localleader>a :A<CR>
autocmd FileType clojure nnoremap <localleader>as :AV<CR>
autocmd FileType clojure nnoremap <localleader>ai :AS<CR>

" Always on rainbow paren
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound