colorscheme solarized
set t_Co=256
set background=dark

" Set font depending on OS
if has("gui_gtk2")
  set guifont=Inconsolata\ 12
elseif has("gui_macvim")
  set guifont=Inconsolata:h16
elseif has("gui_win32")
  set guifont=Consolas:h11:cANSI
endif

" Better line-height
set linespace=8
