" ~/.vimrc or ~/.config/nvim/init.vim
" ref: (n)vim's built-in ':help option' documentation system
"
""" general usability
colorscheme elflord             " default colorscheme is unreadable on a dark console
let skip_defaults_vim=1         " don't source global defaults in absence of ~/.vimrc
set directory=${HOME}/.vim.d//  " keep swapfiles tidy in their own directory
set ignorecase                  " ignore case when searching
set mouse=i                     " enable the mouse in Insert mode
set nomodeline                  " disable modelines for security, see rhbz#1398227
set shada="NONE"                " like viminfo, but worse
set smartcase                   " if ':set ignorecase', use strict case with CAPS
set spelllang=en_ca             " enable spellcheck with ':set spell'
set termguicolors               " enable truecolor support
set viminfo="NONE"              " don't save search history

""" indentation schema
set autoindent                  " enable automatic indentation
set tabstop=2
set shiftwidth=2
set expandtab                   " insert spaces instead of tab
filetype plugin indent on       " indent based on filetype
" use real tabs in makefiles
autocmd FileType make setlocal tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
" indentation is tab/width=8,4 in C's KNF style
autocmd FileType c setlocal tabstop=8 shiftwidth=8 softtabstop=4 noexpandtab
" indentation is four spaces in python
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
" enable spellcheck and line-wrap for markdown files
autocmd FileType markdown setlocal spell formatoptions+=aw textwidth=70
