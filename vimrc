""" source global defaults - as of 8.0
if filereadable(expand('$VIMRUNTIME/defaults.vim'))
  source $VIMRUNTIME/defaults.vim
  let skip_defaults_vim=1   " don't source again in absence of ~/.vimrc
endif

""" security
set nomodeline              " see rhbz#1398227

""" general usability
set viminfo="NONE"          " don't save search history
colorscheme elflord         " default colorscheme is unreadable on dark console
set mouse=i                 " enable the mouse in Insert mode

""" indentation schema
set autoindent              " enable automatic indentation
" set default indentation scheme
filetype plugin indent on   " indent based on filetype
set tabstop=2
set shiftwidth=2
set expandtab               " insert spaces instead of tab
" set language-specific indentation schema
if has("autocmd")
  " use real tabs in makefiles
  autocmd FileType make setlocal tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
  " indentation is tab/width=8,4 in C's KNF style
  autocmd FileType c setlocal tabstop=8 shiftwidth=8 softtabstop=4 noexpandtab
  autocmd FileType cpp setlocal tabstop=8 shiftwidth=8 softtabstop=4 noexpandtab
  " indentation is four spaces in python
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
  " indentation is two spaces in ruby
  autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 expandtab
  " indentation for shell scripts
  autocmd FileType sh setlocal tabstop=2 shiftwidth=2 expandtab
endif

""" search
set ignorecase              " ignore case when searching,
set smartcase               " except when CAPS

""" relocate swapfiles to not live on removable media
set directory=${HOME}/.vim.d//

""" file format support
if has('autocmd')
  " open EPUB as ZIP - requires `unzip`
  if filereadable(expand('$VIMRUNTIME/plugin/zipPlugin.vim'))
    autocmd BufReadCmd *.epub call zip#Browse(expand("<amatch>"))
  endif
endif
