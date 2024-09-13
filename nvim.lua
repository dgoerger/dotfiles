-- ~/.config/nvim/init.lua
-- docs: nvim's built-in ':help option' documentation system

local api = vim.api
local map = vim.keymap.set
local set = vim.opt

set.expandtab  = true    -- use spaces by default instead of tabs
set.ignorecase = true    -- ignore case when searching
set.incsearch  = true    -- search as you type
set.modelines  = 0       -- disable modelines for security, see rhbz#1398227
set.mouse      = ''      -- disable mouse support (jumpy trackpads)
set.shada      = ''      -- disable history file
set.smartcase  = true    -- strict case searching CAPS
set.spelllang  = 'en_ca' -- enable spellcheck with ':set spell'
set.splitbelow = true    -- open new windows below the current one

-- navigating windows
map('n', '<C-UP>',    '<C-W>k')
map('n', '<C-K>',     '<C-W>k')
map('n', '<C-DOWN>',  '<C-W>j')
map('n', '<C-J>',     '<C-W>j')
map('n', '<C-LEFT>',  '<C-W>h')
map('n', '<C-H>',     '<C-W>h')
map('n', '<C-RIGHT>', '<C-W>l')
map('n', '<C-L>',     '<C-W>l')

-- navigating tabs
-- in nvim-tree, open files in new tabs using ctrl+t
map('n', '<C-n>',     '<cmd>tabnext<CR>')
map('n', '<C-p>',     '<cmd>tabprev<CR>')

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
			commit = 'b8bd44d5796503173627d7a1fc51f77ec3a08a63', -- 20240912, there are no releases yet
		},
		{
			'nvim-treesitter/nvim-treesitter',
			lazy = false,
		},
		{
			'nvim-telescope/telescope.nvim',
			lazy = true,
		},
		{
			'nvim-tree/nvim-tree.lua',
			lazy = true,
			tag = 'v1.6', -- 20240912
		},
		{
			'lewis6991/gitsigns.nvim',
			lazy = true,
			tag = 'release',
		},
	},
	-- nota bene: to update, run ':Lazy sync'
	checker = { enabled = false },
	git = { cooldown = 300 },
	performance = { rtp = { disabled_plugins = {
		'editorconfig',
		'gzip',
		'man',
		'netrwPlugin',
		'osc52',
		'rplugin',
		'shada',
		'spellfile',
		'tarPlugin',
		'tohtml',
		'tutor',
		'zipPlugin',
	}}},
})

-- load colour scheme
if (
	(vim.env.TERM:match '-direct') or (vim.env.TERM:match '-256color'))
	and not (vim.env.TERM == 'nsterm-256color'
) then
	-- assume that all -direct (true) and -256color (mostly true)
	-- terminals support truecolour. The main exception is macOS's
	-- Terminal.app (nsterm), so we special case that here.
	set.termguicolors = true
	require('monokai').setup {
		palette = require('monokai').pro
	}
	api.nvim_set_hl(0, 'Normal', {
		guibg=NONE, guifg=NONE, ctermgb=NONE, ctermfg=NONE
	})

	-- configure tree-sitter
	local treesitter = require('nvim-treesitter.configs')
	treesitter.setup {
		ensure_installed = {
			'bash',
			'c',
			'cpp',
			'css',
			'git_rebase',
			'gitattributes',
			'gitcommit',
			'gitignore',
			'go',
			'groovy',
			'haskell',
			'html',
			'java',
			'javascript',
			'json',
			'lua',
			'markdown',
			'perl',
			'php',
			'python',
			'query',
			'rst',
			'rust',
			'typescript',
			'vim',
			'vimdoc',
			'xml',
			'yaml'
		},
		sync_install = false,
		highlight = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = false,
				node_incremental = '.',
				scope_incremental = false,
				node_decremental = false,
			},
		},
		indent = { enable = true },
	}
else
	set.termguicolors = false
end

-- load telescope fuzzy-find
local telescope_builtin = require('telescope.builtin')
local telescope_actions = require('telescope.actions')
require('telescope').setup{
	pickers = {
		buffers = {
			mappings = {
				-- switch to the open tab or window rather than
				-- replace the buffer in the current one
				i = { ["<CR>"] = telescope_actions.select_tab_drop }
			},
			ignore_current_buffer = true,
			show_all_buffers = false,
			sort_last_used = true,
		},
		find_files = {
			find_command = { 'rg', '--one-file-system', '--files', '--iglob', '!.git', '--hidden' },
		},
		grep_string = {
			additional_args = {'--one-file-system', '--iglob', '!.git', '--hidden'}
		},
		live_grep = {
			additional_args = {'--one-file-system', '--iglob', '!.git', '--hidden'}
		}
	}
}

-- telescope keybindings
map('n', '<leader>ff', telescope_builtin.find_files, { desc = "find files" })
map('n', '<leader>fg', telescope_builtin.live_grep, { desc = "live grep" })
map('n', '<leader>fw', telescope_builtin.grep_string, { desc = "find word under cursor" })
map('n', '<leader>gc', telescope_builtin.git_commits, { desc = "search git commits" })
map('n', '<leader>fb', telescope_builtin.buffers, { desc = "search vim buffers" })

-- configure gitsigns
require('gitsigns').setup({
	signcolumn = false,
})

-- configure nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require('nvim-tree').setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = {
			min = 20,
			max = 40,
			padding = 0,
		}
	},
	renderer = {
		indent_markers = {
			enable = true,
			inline_arrows = true,
			icons = {
				corner = '└',
				edge = '│',
				item = '├',
				bottom = '─',
				none = '│',
			},
		},
		icons = {
			glyphs = {
				folder = {
					arrow_closed = '►',
					arrow_open = '▼',
					default = '📁',
					open = '📂',
					symlink = '📁',
					symlink_open = '📂',
					empty = '📂',
					empty_open = '📂',
				},
				default = '',
				symlink = '🔗',
			},
		},
		highlight_modified = 'all',
	},
	modified = {
		enable = true,
		show_on_dirs = true,
		show_on_open_dirs = true,
	},
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
	filters = {
		dotfiles = true,
	},
})
-- automatically close tree view if it's the only remaining buffer
api.nvim_create_autocmd("QuitPre", {
	callback = function()
		local tree_wins = {}
		local floating_wins = {}
		local wins = api.nvim_list_wins()
		for _, w in ipairs(wins) do
			local bufname = api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
			if bufname:match("NvimTree_") ~= nil then
				table.insert(tree_wins, w)
			end
			if api.nvim_win_get_config(w).relative ~= '' then
				table.insert(floating_wins, w)
			end
		end
		if 1 == #wins - #floating_wins - #tree_wins then
			-- Should quit, so we close all invalid windows.
			for _, w in ipairs(tree_wins) do
				api.nvim_win_close(w, true)
			end
		end
	end
})

-- toggle "IDE mode" tree view + gitsigns with ctrl-a
local ToggleIDEMode = function()
	if vim.g.IDEMode then
		vim.g.IDEMode = false
		-- Disable line numbers in all open windows of the current tab.
		-- Without this, line numbers are only disabled in whichever
		-- window has focus, which might be nvim-tree, :help, etc.
		local wins = api.nvim_tabpage_list_wins(0)
		for _, w in ipairs(wins) do
			api.nvim_set_option_value('number', false, { scope = 'local', win = w })
		end
		vim.cmd "NvimTreeClose"
	else
		vim.g.IDEMode = true
		current_win = api.nvim_get_current_win()
		api.nvim_set_option_value('number', true, { scope = 'local', win = 0 })
		vim.cmd "NvimTreeOpen"
		-- nvim-tree likes to steal focus; reset focus to the original window.
		api.nvim_set_current_win(current_win)
	end
	vim.cmd "Gitsigns toggle_linehl"
end
map('n', '<C-a>', ToggleIDEMode)

-- shortcut to open an embedded terminal
local OpenTerminal = function()
	vim.cmd "25split|terminal"
end
map('n', '<C-t>', OpenTerminal)
-- shortcut to return to 'normal mode' within the terminal
map('t', '<C-x>', '<C-\\><C-n>')

-- indentation schema
vim.cmd [[
	set nofoldenable
	autocmd BufRead,BufNewFile /tmp/mutt* set ft=mail spell formatoptions+=aw nosmartindent nocindent indentexpr=
	autocmd BufRead,BufNewFile *.md,*.markdown set ft=mkd syntax=markdown spell formatoptions+=aw textwidth=70 nosmartindent nocindent indentexpr=
	autocmd BufRead,BufNewFile Jenkinsfile*,*.jenkinsfile,*.groovy set ft=groovy syntax=groovy softtabstop=4 shiftwidth=4 expandtab
	autocmd BufRead,BufNewFile *.sls set ft=salt
	autocmd TermOpen * startinsert
	" disable unused providers
	let g:loaded_perl_provider = 0
	let g:loaded_python3_provider = 0
	let g:loaded_ruby_provider = 0
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
