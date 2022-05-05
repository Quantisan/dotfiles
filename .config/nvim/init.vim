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
" Display tabs
set list
set listchars=tab:>-

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

" disable python 2 support
let g:loaded_python_provider = 1
let g:python3_host_prog = '/opt/homebrew/bin/python3'

""""""""""""""""""""""""""
" dein.vim package manager

if &compatible
  set nocompatible               " Be iMproved
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

  " visual
  call dein#add('NLKNguyen/papercolor-theme')
  call dein#add('vim-airline/vim-airline')
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('kshenoy/vim-signature')

  " IDE
  call dein#add('Shougo/defx.nvim')
  call dein#add('octref/RootIgnore')
  call dein#add('godlygeek/tabular')
  call dein#add('mtth/scratch.vim')

  " motion
  call dein#add('easymotion/vim-easymotion')

  " editing helpers
  call dein#add('Shougo/deoplete.nvim')     " auto-complete
  call dein#add('ncm2/float-preview.nvim')
  call dein#add('dense-analysis/ale')       " linting
  call dein#add('scrooloose/nerdcommenter') " commenting
  call dein#add('tpope/vim-surround')       " quoting
  call dein#add('tpope/vim-abolish')        " word variants
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
  call dein#add('Olical/conjure', {'rev': 'v4.*'})
  call dein#add('tpope/vim-salve')               " status support
  call dein#add('tpope/vim-projectionist')       " recommended for vim-salve
  call dein#add('tpope/vim-dispatch')            " async dispatch
  call dein#add('clojure-vim/clojure.vim')       " indentation
  call dein#add('guns/vim-sexp')                 " paredit
  call dein#add('tpope/vim-sexp-mappings-for-regular-people')
  call dein#add('luochen1990/rainbow')           " rainbow paren

  " Go
  call dein#add('fatih/vim-go')

  " Python
  call dein#add('hynek/vim-python-pep8-indent')  " identation
  call dein#add('nvie/vim-flake8')               " style and syntax checking
  call dein#add('tmhedberg/SimpylFold')          " code folding

  call dein#end()
  call dein#save_state()
endif

syntax enable
filetype plugin indent on

""""""""""""""""""""""""""
" plugin settings

" scratch buffer
nmap <leader>sp :ScratchPreview<CR>
let g:scratch_insert_autohide = 0

" auto-completer
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('keyword_patterns', {'clojure': '[\w!$%&*+/:<=>?@\^_~\-\.#]*'})
autocmd CompleteDone * silent! pclose! " close preview window after completion is done
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" defx
autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
  " Define mappings
  nnoremap <silent><buffer><expr> <CR>
  \ defx#do_action('drop')
  nnoremap <silent><buffer><expr> c
  \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
  \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
  \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> E
  \ defx#do_action('open', 'vsplit')
  nnoremap <silent><buffer><expr> P
  \ defx#do_action('open', 'pedit')
  nnoremap <silent><buffer><expr> o
  \ defx#do_action('open_or_close_tree')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
  \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> C
  \ defx#do_action('toggle_columns',
  \                'mark:indent:icon:filename:type:size:time')
  nnoremap <silent><buffer><expr> S
  \ defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> d
  \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> x
  \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> yy
  \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
  \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> ;
  \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~
  \ defx#do_action('cd')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
  \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> *
  \ defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> <C-l>
  \ defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-g>
  \ defx#do_action('print')
  nnoremap <silent><buffer><expr> cd
  \ defx#do_action('change_vim_cwd')
endfunction

" vim-terraform
let g:terraform_align=1
let g:terraform_fmt_on_save=1

" Black
autocmd BufWritePre *.py execute ':Black'

" fzf.vim respect gitignore
let $FZF_DEFAULT_COMMAND = 'ag -g ""'

" ALE
let g:ale_linters = {'clojure': ['clj-kondo']}

""""""""""""""""""""""""""
" Clojure

" Conjure
let g:conjure#log#hud#width = 0.8
let g:float_preview#docked = 0

" rainbow
let g:rainbow_active = 1

" Clojure.vim
let g:clojure_align_subforms = 1 " emulate clojure-mode indentation

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
if strftime("%H") >= 5 && strftime("%H") < 19
  set background=light
else
  set background=dark
endif

""""""""""""""""""""""""""
" key bindings

" disable search highlight
nmap <leader>q :nohlsearch<CR>

map ` :Defx `expand('%:p:h')` -search=`expand('%:p')`<CR>

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
nmap <leader>gb :GBrowse<CR>
nmap <leader>gs :Git<CR>
nmap <leader>gd :Gvdiffsplit<CR>
nmap <leader>gl :Git log<CR>
nmap <leader>gp :Git push<CR>
