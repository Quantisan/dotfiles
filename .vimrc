" Use the Solarized Dark theme
set background=dark
colorscheme solarized

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
" Disable swapfiles altogether
set noswapfile

" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*

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
" Replace tab with spaces
set expandtab
" Round indent to tabs
set shiftwidth=2
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
" Disable line wrap
set nowrap

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

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" My bundles here:
Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-fugitive'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'YankRing.vim'
Plugin 'godlygeek/tabular'
Plugin 'bling/vim-airline'
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/syntastic'
Plugin 'majutsushi/tagbar'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'gitignore'
Plugin 'kshenoy/vim-signature'

" for Python
Plugin 'python.vim'
Plugin 'python_match.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'hynek/vim-python-pep8-indent'

" for Clojure
Plugin 'tpope/vim-fireplace'
Plugin 'paredit.vim'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'tpope/vim-classpath'

" Javascript
Plugin 'marijnh/tern_for_vim'
Plugin 'pangloss/vim-javascript'
Plugin 'Raimondi/delimitMate'

" Go
Plugin 'fatih/vim-go'

" End of my bundles

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" End of Vundle config
""""""""""""""""""""""

" NERDTree settings
let NERDTreeIgnore=['^dist$[[dir]]', '^Godeps[[dir]]', '^classes[[dir]]', '^target[[dir]]', '\.class$', '\.pyc$', '\.pyo$', '\.rbc$', '\.rbo$', '\.class$', '\.o$', '\~$']
map <Leader>n :NERDTreeToggle<CR> :NERDTreeMirror<CR>

" CtrlP ignore
set wildignore+=*.class,*.pyc,*.class,*.css

" map CtrlP buffer
nmap ; :CtrlPBuffer<CR>

" bind Fugitive functions
nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gp :Git push<CR>

" binding nerdcommenter
map <D-/> <plug>NERDCommenterToggle<CR>
imap <D-/> <Esc><plug>NERDCommenterToggle<CR>i

nmap <Leader>q :nohlsearch<CR>
nmap <silent><C-e> :e#<CR>

nnoremap <silent><C-J> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><C-K> :set paste<CR>m`O<Esc>``:set nopaste<CR>
nnoremap <silent> <F11> :YRShow<CR>
nnoremap <C-k> O<Esc>j
nnoremap <C-j> o<Esc>k

" bind :Ack to Cmd-F
nnoremap <D-F> :Ack<space>

let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree']

"""" Clojure """"

let g:paredit_electric_return = 0
let g:clojure_align_multiline_strings = 1
let g:clojure_maxlines = 1000
autocmd FileType clojure setlocal lispwords+=facts,fact

" map Clojure testing and namespace switch shortcuts
autocmd FileType clojure nnoremap <localleader>rt :Require!<Bar>Eval (clojure.test/run-tests)<CR>
autocmd FileType clojure nnoremap <localleader>a :A<CR>
autocmd FileType clojure nnoremap <localleader>a<C-v> :AV<CR>
autocmd FileType clojure nnoremap <localleader>as :AS<CR>

" Always on rainbow paren
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound

"""" Python """"

" Settings for indentation and line-wrapping to values compliant with PEP 8
" Reference http://docs.python-guide.org/en/latest/dev/env/

" operation >> indents 4 columns; << unindents 4 columns
" insert spaces when hitting TABs
" an hard TAB displays as 4 columns
" insert/delete 4 spaces when hitting a TAB/BACKSPACE
" round indent to multiple of 'shiftwidth'
" align the new line indent with the previous line
au FileType python setlocal shiftwidth=4 expandtab tabstop=4 softtabstop=4 shiftround autoindent
au FileType python setlocal colorcolumn=80

let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args = '--ignore="E501"'

" Remap jedi-vim command as it conflicts with NerdTree shortcut
let g:jedi#usages_command = "<leader>u"

"""" Javascript """"
au FileType javascript setlocal softtabstop=2 shiftwidth=2 expandtab
au FileType javascript let b:delimitMate_expand_cr=1
au FileType javascript let b:delimitMate_expand_space=1
au FileType javascript IndentGuidesEnable

"""" Go """"
au FileType go setlocal colorcolumn=80
au FileType go setlocal formatoptions+=t
au FileType go setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
au FileType go setlocal nolist
au FileType go setlocal foldmethod=syntax
au FileType go setlocal foldlevelstart=1
au FileType go setlocal foldnestmax=3
" press Space to toggle the current fold open/closed
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>

let g:go_disable_autoinstall = 1
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
au FileType go nmap <leader>t <Plug>(go-test)

