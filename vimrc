" ~/.vimrc or ~/.config/nvim/init.vim
" ref: (n)vim's built-in ':help option' documentation system
"
""" general usability
if filereadable(expand("$VIMRUNTIME/colors/elflord.vim"))
	colorscheme elflord	" default colorscheme is unreadable on a dark console
end
if has('skip_defaults_vim')
	let skip_defaults_vim=1	" don't source global defaults in absence of ~/.vimrc
endif
set directory=${HOME}/.vim.d//	" keep swapfiles tidy in their own directory
set ignorecase			" ignore case when searching
set mouse=i			" enable the mouse in Insert mode
set nojoinspaces		" insert ONE space between sentences, not TWO
set nomodeline			" disable modelines for security, see rhbz#1398227
if has('shada')
	set shada="NONE"	" like viminfo, but worse
endif
set smartcase			" if ':set ignorecase', use strict case with CAPS
set spelllang=en_ca		" enable spellcheck with ':set spell'
if has('nvim')
	set termguicolors	" enable truecolor support in neovim
endif
set viminfo="NONE"		" don't save search history

""" indentation schema
set autoindent			" enable automatic indentation
set tabstop=8
set shiftwidth=8
set softtabstop=4
set noexpandtab			" insert tabs instead of spaces
filetype plugin indent on	" indent based on filetype
" indentation per C's KNF style
autocmd FileType c setlocal tabstop=8 shiftwidth=8 softtabstop=4 noexpandtab
" use real tabs in calendars
autocmd BufNewFile,BufRead .calendar setfiletype calendar
autocmd FileType calendar setlocal tabstop=8 shiftwidth=8 noexpandtab
" use real tabs in makefiles
autocmd FileType make setlocal tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
" enable spellcheck, word-wrap, and expandtab for markdown and mail files
autocmd FileType mail setlocal spell formatoptions+=aw textwidth=70 expandtab
autocmd FileType markdown setlocal spell formatoptions+=aw textwidth=70 expandtab
" python: indentation is customarily four spaces
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
" ruby: indentation is customarily two spaces
autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 expandtab
