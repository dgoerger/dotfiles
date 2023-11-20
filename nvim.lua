-- ~/.config/nvim/init.lua
-- docs: nvim's built-in ':help option' documentation system

local set         = vim.opt

vim.cmd [[
	colorscheme elflord
]]

set.expandtab     = true        -- use spaces by default instead of tabs
set.ignorecase    = true        -- ignore case when searching
set.incsearch     = true        -- search as you type
set.modelines     = 0           -- disable modelines for security, see rhbz#1398227
set.mouse         = ''          -- disable mouse support (jumpy trackpads)
set.shada         = ''          -- disable history file
set.smartcase     = true        -- strict case searching CAPS
set.spelllang     = 'en_ca'     -- enable spellcheck with ':set spell'
set.termguicolors = true        -- enable truecolour support

-- indentation schema
vim.cmd [[
	set nofoldenable
	autocmd BufNewFile,BufRead .calendar set ft=calendar noexpandtab
	autocmd BufRead,BufNewFile /tmp/mutt* set ft=mail spell formatoptions+=aw nosmartindent nocindent indentexpr=
	autocmd BufRead,BufNewFile *.md,*.markdown set ft=mkd syntax=markdown spell formatoptions+=aw textwidth=70 nosmartindent nocindent indentexpr=
	autocmd BufRead,BufNewFile Jenkinsfile*,*.jenkinsfile set ft=groovy syntax=groovy
]]
