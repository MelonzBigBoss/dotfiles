vim.cmd([[set mouse=]])
vim.cmd([[set noswapfile]])
vim.opt.winborder = "rounded"
vim.opt.tabstop = 4
vim.opt.wrap = true
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.spell = false
vim.opt.spelllang = "en_us"
local spell_filetypes = { "text", "typst", "gitcommit", "markdown" }

vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" }, -- Colorscheme
	{ src = "https://github.com/stevearc/oil.nvim" }, -- Files

	{ src = "https://github.com/nvim-telescope/telescope.nvim" }, -- Finding
	{ src = "https://github.com/nvim-lua/plenary.nvim" }, -- dependency for telescope

	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }, -- Highlighting
	{ src = "https://github.com/neovim/nvim-lspconfig" }, -- LSP
	{ src = "https://github.com/kdheepak/lazygit.nvim" }, -- Github
	{ src = "https://github.com/akinsho/toggleterm.nvim" }, -- Terminal

	{ src = "https://github.com/mason-org/mason.nvim" }, -- LSPs
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" }, -- automatically loads lsp servers

	{ src = "https://github.com/chomosuke/typst-preview.nvim" }, -- Typst Preview
})

vim.cmd("colorscheme kanagawa-dragon")
vim.cmd(":hi statusline guibg=NONE")

require("mason").setup()
require("mason-lspconfig").setup()
require("telescope").setup({
	defaults = {
		file_ignore_patterns = { "CMakeFiles/", "%.cmake" },
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method("textDocument/completion") then
			-- Optional: trigger autocompletion on EVERY keypress. May be slow!
			local chars = {}
			for i = 32, 126 do
				table.insert(chars, string.char(i))
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})
vim.cmd([[set completeopt+=menuone,noselect,popup]])

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = { library = vim.api.nvim_get_runtime_file("", true) },
		},
	},
})

require("oil").setup({
	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
		autosave_changes = true,
	},
	float = {
		max_width = 0.7,
		max_height = 0.6,
		border = "rounded",
	},
	keymaps = {},
})

require("toggleterm").setup({
	open_mapping = [[<C-t>]],
	direction = "float",
	autochdir = true,
	float_opts = {
		border = "rounded",
	},
})

require("typst-preview").setup({
	dependencies_bin = {
		["tinymist"] = "tinymist",
	},
})

vim.api.nvim_create_augroup("Spellcheck", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
	group = "Spellcheck", -- Grouping the command for easier management
	pattern = spell_filetypes, -- Only apply to these file types
	callback = function()
		vim.opt_local.spell = true -- Enable spellcheck for these file types
	end,
	desc = "Enable spellcheck for defined filetypes", -- Description for clarity
})

local tele = require("telescope.builtin")

local map = vim.keymap.set
vim.g.mapleader = " "
map("n", "<leader>q", "<Cmd>q<CR>")
map("n", "<leader>w", "<Cmd>update<CR>")
map("n", "<leader>lf", vim.lsp.buf.format)
map("n", "<leader>h", tele.help_tags)
map("n", "<leader>g", tele.live_grep)
map("n", "<leader>f", tele.find_files)
map("n", "<leader>r", tele.buffers)
map("n", "<leader>e", "<Cmd>Oil<CR>")
map("n", "<leader>v", "<Cmd>e $MYVIMRC<CR>")
map("n", "<leader>tp", "<Cmd>TypstPreview<CR>")
map("n", "<leader>tc", "<Cmd>!typst compile %:p<CR><CR>")
map("n", "<leader>G", "<Cmd>LazyGit<CR>")
map("n", "<C-t>", "<Cmd>ToggleTerm<CR>")
map("n", "<leader>bd", "<Cmd>bd<CR>")
map("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to Definition" })
map({ "v", "x", "n" }, "<C-y>", '"+y')
map("n", "<C-p>", '"+p')
map("i", "<C-j>", "<C-n>", { noremap = true, silent = true, desc = "Next completion item" })
map("i", "<C-k>", "<C-p>", { noremap = true, silent = true, desc = "Previous completion item" })
map("i", "<C-h>", "<C-e>", { noremap = true, silent = true, desc = "Reject Auto Complete" })
map("i", "<C-l>", "<C-y>", { noremap = true, silent = true, desc = "Accept Auto Complete" })
map("n", "<leader>C", "z=")
map("n", "<leader>c", "1z=")
map("i", "<C-s>", "<C-x>s")
