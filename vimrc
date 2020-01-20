" ~/.vimrc or ~/.config/nvim/init.vim
" ref: (n)vim's built-in ':help option' documentation system
"
""" disable various things by default for greater speed
syntax off
filetype off
filetype plugin indent off
set noloadplugins		" don't autoload unused plugins

""" general usability
if filereadable(expand("$VIMRUNTIME/colors/elflord.vim"))
	colorscheme elflord	" default colorscheme is unreadable on a dark console
end
if has('skip_defaults_vim')
	let skip_defaults_vim=1	" don't source global defaults
endif
set directory=${HOME}/.vim.d//	" keep swapfiles tidy in their own directory
set ignorecase			" ignore case when searching
set mouse=i			" enable the mouse in Insert mode
set noexpandtab			" insert tabs instead of spaces
set nojoinspaces		" insert ONE space between sentences, not TWO
set nomodeline			" disable modelines for security, see rhbz#1398227
if has('shada')
	set shada="NONE"	" like viminfo, but worse
endif
set smartcase			" if ':set ignorecase', use strict case with CAPS
set spelllang=en_ca		" enable spellcheck with ':set spell'
set viminfo="NONE"		" don't save search history

""" indentation schema
" C, CUDA: indentation per style(9)
autocmd BufRead,BufNewFile *.[ch] setlocal autoindent cindent cinoptions=(4200,u4200,+0.5s,*500,:0,t0,U4200 indentexpr=IgnoreParenIndent() indentkeys=0{,0},0),:,0#,!^F,o,O,e noexpandtab shiftwidth=8 tabstop=8 textwidth=80
"autocmd BufNewFile,BufRead *.cu,*.cuh setlocal autoindent cindent noexpandtab shiftwidth=8 tabstop=80 textwidth=80
" calendar, make: use real tabs
autocmd BufNewFile,BufRead .calendar setlocal tabstop=8 shiftwidth=8 noexpandtab
autocmd BufNewFile,BufRead *[mM]akefile setlocal autoindent tabstop=8 shiftwidth=8 noexpandtab
" go: custom style
"autocmd BufNewFile,BufRead *.go setlocal autoindent nolisp indentexpr=GoIndent(v:lnum) indentkeys+=<:>,0=},0=)
" mail, markdown: enable spellcheck, word-wrap, and expandtab
autocmd BufRead,BufNewFile /tmp/mutt* setlocal spell formatoptions+=aw textwidth=70 expandtab nosmartindent nocindent indentexpr=
autocmd BufRead,BufNewFile *.md,*.markdown setlocal spell formatoptions+=aw textwidth=70 expandtab nosmartindent nocindent indentexpr=
" python: indentation is customarily four spaces
autocmd BufRead,BufNewFile *.py setlocal nolisp autoindent indentkeys=0{,0},0),0],:,!^F,o,O,e,<:>,=elif,=except tabstop=4 shiftwidth=4 expandtab
" ruby: indentation is customarily two spaces
autocmd BufRead,BufNewFile *.rb setlocal autoindent indentkeys=0{,0},0),0],!^F,o,O,e,:,.,=end,=else,=elsif,=when,=ensure,=rescue,==begin,==end,=private,=protected,=public tabstop=2 shiftwidth=2 expandtab
" yaml
autocmd BufRead,BufNewFile *.yaml,*.yml setlocal autoindent indentkeys=!^F,o,O,0#,0},0],<:>,0- nosmartindent
" shell
autocmd BufRead,BufNewFile *.sh setlocal autoindent cindent indentkeys=0{,0},0),0],!^F,o,O,e,0=then,0=do,0=else,0=elif,0=fi,0=esac,0=done,0=end,),0=;;,0=;&,0=fin,0=fil,0=fip,0=fir,0=fix noexpandtab nosmartindent shiftwidth=8 tabstop=8

""" functions
" C style(9): ignore indents caused by parentheses
function! IgnoreParenIndent()
	let indent = cindent(v:lnum)
	if indent > 4000
		if cindent(v:lnum - 1) > 4000
			return indent(v:lnum - 1)
		else
			return indent(v:lnum - 1) + 4
		endif
	else
		return (indent)
	endif
endfunction

" golang
"function! GoIndent(lnum)
"	let l:prevlnum = prevnonblank(a:lnum-1)
"	if l:prevlnum == 0
"		" top of file
"		return 0
"	endif
"	" grab the previous and current line, stripping comments.
"	let l:prevl = substitute(getline(l:prevlnum), '//.*$', '', '')
"	let l:thisl = substitute(getline(a:lnum), '//.*$', '', '')
"	let l:previ = indent(l:prevlnum)
"	let l:ind = l:previ
"	if l:prevl =~ '[({]\s*$'
"		" previous line opened a block
"		let l:ind += shiftwidth()
"	endif
"	if l:prevl =~# '^\s*\(case .*\|default\):$'
"		" previous line is part of a switch statement
"		let l:ind += shiftwidth()
"	endif
"	" TODO: handle if the previous line is a label.
"	if l:thisl =~ '^\s*[)}]'
"		" this line closed a block
"		let l:ind -= shiftwidth()
"	endif
"	" Colons are tricky.
"	" We want to outdent if it's part of a switch ("case foo:" or "default:").
"	" We ignore trying to deal with jump labels because (a) they're rare, and
"	" (b) they're hard to disambiguate from a composite literal key.
"	if l:thisl =~# '^\s*\(case .*\|default\):$'
"		let l:ind -= shiftwidth()
"	endif
"	return l:ind
"endfunction
