colorscheme solarized
set t_Co=256
" Use Solarized Light for daytime and Dark for nighttime
if strftime("%H") >= 7 && strftime("%H") <= 17
  set background=light
else
  set background=dark
endif

" Set font depending on OS
if has("gui_gtk2")
  set guifont=Inconsolata\ 12
elseif has("gui_macvim")
  set guifont=Source\ Code\ Pro:h14
elseif has("gui_win32")
  set guifont=Consolas:h11:cANSI
endif

" Better line-height
set linespace=8
