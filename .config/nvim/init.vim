" Set standard file encoding
set encoding=utf8 nobomb
" No special per file vim override configs
set nomodeline
" Stop word wrapping
set nowrap
  " Except... on Markdown. That's good stuff.
  autocmd FileType markdown setlocal wrap
" Adjust system undo levels
set undolevels=100
" Use system clipboard
set clipboard=unnamed
" Change mapleader
let mapleader=","
let maplocalleader = "\\"

" Set tab width and convert tabs to spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
" Don't let Vim hide characters or make loud dings
set conceallevel=1
set noerrorbells
" Number gutter
set number
" Use search highlighting
set hlsearch
" Space above/beside cursor from screen edges
set scrolloff=1
set sidescrolloff=5
" Use true colour in terminal
set termguicolors

""""""""""""""""""""""""""
" dein.vim package manager

if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.vim/bundles/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state(expand('~/.vim/bundles'))
  call dein#begin(expand('~/.vim/bundles'))

  " Let dein manage dein
  " Required:
  call dein#add(expand('~/.vim/bundles/repos/github.com/Shougo/dein.vim'))

  " visual
  call dein#add('NLKNguyen/papercolor-theme')
  call dein#add('vim-airline/vim-airline')
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('kshenoy/vim-signature')

  " IDE
  call dein#add('Shougo/unite.vim')
  call dein#add('Shougo/vimfiler.vim', { 'on': 'VimFiler', 'depends': 'unite.vim' }) " file explorer
  call dein#add('octref/RootIgnore')

  " motion
  call dein#add('easymotion/vim-easymotion')

  " editing helpers
  call dein#add('Shougo/deoplete.nvim')     " auto-complete
  call dein#add('w0rp/ale')                 " linting
  call dein#add('scrooloose/nerdcommenter') " commenting
  call dein#add('tpope/vim-surround')       " quoting
  call dein#add('editorconfig/editorconfig-vim')

  " CLI tools integration
  call dein#add('tpope/vim-fugitive')       " Git
  call dein#add('tpope/vim-rhubarb')        " Git
  " ./install --all so the interactive script doesn't block
  call dein#add('junegunn/fzf', { 'build': './install --all' })
  call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })

  "" Language-specific ""

  call dein#add('hashivim/vim-terraform')

  " Clojure
  call dein#add('clojure-vim/acid.nvim')         " nREPL integration
  call dein#add('guns/vim-clojure-static')       " indentation
  call dein#add('guns/vim-sexp')                 " paredit
  call dein#add('tpope/vim-sexp-mappings-for-regular-people')
  call dein#add('luochen1990/rainbow')           " rainbow paren

  " Go
  call dein#add('fatih/vim-go')

  " Python
  call dein#add('hynek/vim-python-pep8-indent')  " identation
  call dein#add('nvie/vim-flake8')               " style and syntax checking
  call dein#add('tmhedberg/SimpylFold')          " code folding

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable


" disable python 2 support
let g:loaded_python_provider = 1
let g:python3_host_prog = '/usr/local/bin/python3'

""""""""""""""""""""""""""
" plugin settings

" deoplete
let g:deoplete#enable_at_startup = 1

" vimfiler
" Enable file operation commands.
" Edit file by tabedit.
call vimfiler#custom#profile('default', 'context', {
      \ 'safe' : 0,
      \ })

" vimfiler use Textmate-like icons.
let g:vimfiler_tree_leaf_icon = ' '
let g:vimfiler_tree_opened_icon = '▾'
let g:vimfiler_tree_closed_icon = '▸'
let g:vimfiler_file_icon = '-'
let g:vimfiler_marked_file_icon = '*'

" vim-terraform
let g:terraform_align=1

""""""""""""""""""""""""""
" Clojure

" rainbow
let g:rainbow_active = 1

" vim-clojure-static
let g:clojure_align_multiline_strings = 1
setlocal lispwords+=go,go-loop

" for compojure
setlocal lispwords+=context
setlocal lispwords+=GET
setlocal lispwords+=PUT
setlocal lispwords+=POST
setlocal lispwords+=DELETE

""""""""""""""""""""""""""
" Go

" configure indentation
au FileType go set noexpandtab
au FileType go set shiftwidth=4
au FileType go set softtabstop=4
au FileType go set tabstop=4

" enable lots of highlights
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1

" enable same variable under cursor highlighting
let g:go_auto_sameids = 1

" auto-import dependencies
let g:go_fmt_command = "goimports"

" show type information in status line
let g:go_auto_type_info = 1

" shortcut to jump to definition
au FileType go nmap <F12> <Plug>(go-def)

""""""""""""""""""""""""""
" Python

" run Flake8 every time when saving a .py file
autocmd BufWritePost *.py call Flake8()

""""""""""""""""""""""""""
" Theme
colorscheme PaperColor

" Choose light/dark colorscheme based on time of day
if strftime("%H") >= 7 && strftime("%H") < 18
  set background=light
else
  set background=dark
endif

""""""""""""""""""""""""""
" key bindings

" disable search highlight
nmap <leader>q :nohlsearch<CR>

map ` :VimFiler -explorer<CR>
map ~ :VimFilerCurrentDir -explorer -find<CR>

" fzf.vim bindings
nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>a :Buffers<CR>
nnoremap <silent> <leader>A :Windows<CR>
nnoremap <silent> <leader>; :BLines<CR>
nnoremap <silent> <leader>o :BTags<CR>
nnoremap <silent> <leader>O :Tags<CR>
nnoremap <silent> <leader>? :History<CR>
nnoremap <silent> <leader>gl :Commits<CR>
nnoremap <silent> <leader>ga :BCommits<CR>
nnoremap <silent> <leader>/ :execute 'Ag ' . input('Ag/')<CR>

" fzf.vim insert mode completion
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" bind Fugitive functions
nmap <leader>gb :Gbrowse<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gp :Git push<CR>
