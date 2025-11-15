-- Neovim configuration
-- Basic settings that mirror vim functionality

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true          -- Line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.mouse = "a"            -- Enable mouse
vim.opt.ignorecase = true      -- Case insensitive search
vim.opt.smartcase = true       -- Smart case search
vim.opt.hlsearch = true        -- Highlight search
vim.opt.wrap = false           -- No line wrapping
vim.opt.tabstop = 4           -- Tab width
vim.opt.shiftwidth = 4        -- Indent width
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.autoindent = true     -- Auto indent
vim.opt.smartindent = true    -- Smart indent

-- Better colors
vim.opt.termguicolors = true

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Basic keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Clear search highlighting with Escape
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Stay in visual mode when indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

print("Neovim configuration loaded!")