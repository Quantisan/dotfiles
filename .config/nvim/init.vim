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
  call dein#add('bling/vim-airline')

  " motion
  call dein#add('easymotion/vim-easymotion')

  " editing helpers
  call dein#add('Shougo/deoplete.nvim') " auto-complete
  call dein#add('w0rp/ale')             " linting

  " CLI tools integration
  call dein#add('tpope/vim-fugitive')
  call dein#add('tpope/vim-rhubarb')
  call dein#add('mileszs/ack.vim')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable
""""""""""""""""""""""""""

""""""""""""""""""""""""""
" Theme
colorscheme PaperColor

" Choose light/dark colorscheme based on time of day
if strftime("%H") >= 7 && strftime("%H") < 19
  set background=light
else
  set background=dark
endif
""""""""""""""""""""""""""

""""""""""""""""""""""""""
" misc. plugin settings

let g:deoplete#enable_at_startup = 1

" set Ack to use Ag
let g:ackprg = 'ag --nogroup --nocolor --column'
" bind :Ack to key
nnoremap <leader>f :Ack<space>
