-- Neovim configuration
-- Basic settings with Catppuccin theme

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

-- Install path for manual plugin installation
local plugin_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start"

-- Function to clone plugin if it doesn't exist
local function ensure_plugin(repo, name)
    local install_path = plugin_path .. "/" .. name
    if vim.fn.isdirectory(install_path) == 0 then
        print("Installing " .. name .. "...")
        vim.fn.system({
            "git", "clone", "--depth=1",
            "https://github.com/" .. repo,
            install_path
        })
        print(name .. " installed!")
        return true
    end
    return false
end

-- Install Catppuccin theme (manual installation)
local catppuccin_installed = ensure_plugin("catppuccin/nvim", "catppuccin")

-- If we just installed Catppuccin, restart Neovim to load it
if catppuccin_installed then
    print("Catppuccin installed! Please restart Neovim.")
    return
end

-- Configure Catppuccin (only if already installed)
if pcall(require, "catppuccin") then
    require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
            comments = { "italic" },
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
            cmp = false,
            gitsigns = false,
            nvimtree = false,
            treesitter = false,
            notify = false,
            mini = false,
        },
    })

    -- Apply the colorscheme
    vim.cmd.colorscheme("catppuccin")
else
    -- Fallback to a built-in colorscheme if Catppuccin isn't available
    vim.cmd.colorscheme("habamax")  -- A nice built-in dark theme
end

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

-- Theme switching keymaps (for learning/testing)
vim.keymap.set("n", "<leader>tm", ":colorscheme catppuccin-mocha<CR>", { desc = "Catppuccin Mocha" })
vim.keymap.set("n", "<leader>tl", ":colorscheme catppuccin-latte<CR>", { desc = "Catppuccin Latte" })
vim.keymap.set("n", "<leader>tf", ":colorscheme catppuccin-frappe<CR>", { desc = "Catppuccin Frappe" })
vim.keymap.set("n", "<leader>tc", ":colorscheme catppuccin-macchiato<CR>", { desc = "Catppuccin Macchiato" })

print("Neovim configuration loaded with Catppuccin theme!")
