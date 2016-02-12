""" FILE SUPPORT
" open epubs as zip files
au BufReadCmd *.epub call zip#Browse(expand("<amatch>"))

""" this is VIM
set nocompatible
syntax on
"set paste
set autoindent
set smartindent

""" SEARCH
" ignore case when searching, except when caps
set ignorecase
set smartcase
" incremental search / highlight while typing
set incsearch
" assume global in search/replace
set gdefault

""" HYGIENE
" don't save search history
set viminfo="NONE"

""" MOUSE
" permit clicking to a specific point on the line
if has('mouse')
  set mouse=a
endif
