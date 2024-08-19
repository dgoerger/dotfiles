-- ~/.config/nvim/init.lua
-- docs: nvim's built-in ':help option' documentation system

local api = vim.api
local map = vim.keymap.set
local set = vim.opt

set.expandtab = true    -- use spaces by default instead of tabs
set.ignorecase= true    -- ignore case when searching
set.incsearch = true    -- search as you type
set.modelines = 0       -- disable modelines for security, see rhbz#1398227
set.mouse     = ''      -- disable mouse support (jumpy trackpads)
set.shada     = ''      -- disable history file
set.smartcase = true    -- strict case searching CAPS
set.spelllang = 'en_ca' -- enable spellcheck with ':set spell'
set.tgc       = true    -- enable truecolour support

-- ctrl+h/j/k/l keybindings for navigating windows
map('n', '<C-UP>',    '<C-W>k')
map('n', '<C-K>',     '<C-W>k')
map('n', '<C-DOWN>',  '<C-W>j')
map('n', '<C-J>',     '<C-W>j')
map('n', '<C-LEFT>',  '<C-W>h')
map('n', '<C-H>',     '<C-W>h')
map('n', '<C-RIGHT>', '<C-W>l')
map('n', '<C-L>',     '<C-W>l')

-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
set.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- configure lazy.nvim
require("lazy").setup({
	spec = {
		{
			'tanvirtin/monokai.nvim',
			lazy = false,
			priority = 10000,
		},
		{
			'nvim-treesitter/nvim-treesitter',
			lazy = false,
		},
		{
			'NeogitOrg/neogit',
			lazy = false,
			dependencies = {
				'nvim-lua/plenary.nvim',
				'sindrets/diffview.nvim',
				'nvim-telescope/telescope.nvim',
				'nvim-treesitter/nvim-treesitter',
			}
		},
	},
	-- nota bene: to update, run ':Lazy sync'
	checker = { enabled = false },
	git = { cooldown = 300 },
	performance = { rtp = { disabled_plugins = {
		'editorconfig',
		'gzip',
		'osc52',
		'shada',
		'spellfile',
		'tarPlugin',
		'tohtml',
		'tutor',
		'zipPlugin',
	}}}

})

-- load colour scheme
require('monokai').setup { palette = require('monokai').pro }

-- configure tree-sitter
local treesitter = require('nvim-treesitter.configs')
treesitter.setup {
	ensure_installed = {
		'bash',
		'c',
		'cpp',
		'css',
		'go',
		'groovy',
		'haskell',
		'html',
		'java',
		'javascript',
		'json',
		'lua',
		'perl',
		'php',
		'python',
		'query',
		'rust',
		'typescript',
		'vim',
		'vimdoc',
		'yaml'
	},
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = true },
}

-- load neogit
local neogit = require('neogit')
neogit.setup {
	graph_style = "unicode",
	ignored_settings = {
		"NeogitPushPopup--force-with-lease",
		"NeogitPushPopup--force",
		"NeogitPullPopup--rebase",
		"NeogitCommitPopup--allow-empty",
		"NeogitRevertPopup--no-edit",
	},
	disable_line_numbers = true,
	console_timeout = 2000,
	auto_show_console = true,
	auto_close_console = true,
	commit_editor = {
		kind = "tab",
		show_staged_diff = true,
		staged_diff_split_kind = "auto",
	},
}

-- load telescope fuzzy-find
local builtin = require('telescope.builtin')
require('telescope').setup{
	pickers = {
		find_files = {
			find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
		},
		grep_string = {
			additional_args = {'--hidden'}
		},
		live_grep = {
			additional_args = {'--hidden'}
		}
	}
}

-- telescope keybindings
map('n', '<leader>ff', builtin.find_files, { desc = "find files" })
map('n', '<leader>fg', builtin.live_grep, { desc = "live grep" })
map('n', '<leader>fw', builtin.grep_string, { desc = "find word under cursor" })
map('n', '<leader>gc', builtin.git_commits, { desc = "search git commits" })

-- indentation schema
vim.cmd [[
	set nofoldenable
	autocmd BufNewFile,BufRead .calendar set ft=calendar noexpandtab
	autocmd BufRead,BufNewFile /tmp/mutt* set ft=mail spell formatoptions+=aw nosmartindent nocindent indentexpr=
	autocmd BufRead,BufNewFile *.md,*.markdown set ft=mkd syntax=markdown spell formatoptions+=aw textwidth=70 nosmartindent nocindent indentexpr=
	autocmd BufRead,BufNewFile Jenkinsfile*,*.jenkinsfile set ft=groovy syntax=groovy
	autocmd BufRead,BufNewFile *.sls set ft=salt
]]

-- autoformatting for python
api.nvim_create_augroup("python_auto_format", {clear = true})
api.nvim_create_autocmd({"BufWritePost"}, {
	desc = "autoformat code using ruff",
	group = "python_auto_format",
	callback = function (opts)
		if vim.bo[opts.buf].filetype == "python" then
			vim.cmd "!/usr/local/bin/ruff --quiet --fix %"
			vim.cmd "edit!"
			vim.cmd "redraw!"
		end
	end
})
