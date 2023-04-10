vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerInstall
  augroup end
]]

local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd "packadd packer.nvim"
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    print("packer not installed")
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

return packer.startup(function(use)
    use "antoinemadec/FixCursorHold.nvim"
    use "wbthomason/packer.nvim" -- Have packer manage itself
    use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
    use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
    use "kyazdani42/nvim-web-devicons"

    use "Mofiqul/vscode.nvim" -- vscode theme

    -- file explorer
    use {
        "kyazdani42/nvim-tree.lua",
        requires = {
            "kyazdani42/nvim-web-devicons", -- optional, for file icon
        }
    }

    -- autosave
    use "Pocco81/auto-save.nvim"
    use "djoshea/vim-autoread"

    -- configure lsp
    use "neovim/nvim-lspconfig" -- Collection of configurations for the built-in LSP client
    use "williamboman/nvim-lsp-installer"

    -- telescope
    use {
        "nvim-telescope/telescope.nvim",
        requires = { { "nvim-lua/plenary.nvim" } }
    }

    -- delete buffer without close window
    use "moll/vim-bbye"

    -- smart comment for .vue or .jsx
    use "numToStr/Comment.nvim"
    use 'JoosepAlviste/nvim-ts-context-commentstring'

    -- bufferline
    use { 'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons', branch = "main" }

    -- cmp
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-cmdline"
    use "hrsh7th/nvim-cmp"

    -- luasnip
    use "L3MON4D3/LuaSnip"
    use "saadparwaiz1/cmp_luasnip"
    use "rafamadriz/friendly-snippets"

    -- better syntax highlight, rainbow pairs
    use "p00f/nvim-ts-rainbow"
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
    }


    use "lukas-reineke/indent-blankline.nvim"

    -- git
    use "lewis6991/gitsigns.nvim"
    use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

    -- status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- null-ls, inject formatting for golang, lua
    use "jose-elias-alvarez/null-ls.nvim"

    -- autopairs
    use "windwp/nvim-autopairs"

    -- toggle term
    use "akinsho/toggleterm.nvim"

    -- navigate between neovim and tmux pane
    use "christoomey/vim-tmux-navigator"

    -- debugger adapter protocol
    use "mfussenegger/nvim-dap"
    use "theHamsta/nvim-dap-virtual-text"
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
    use "nvim-telescope/telescope-dap.nvim"
    use "leoluz/nvim-dap-go"

    -- which key
    use "folke/which-key.nvim"

    -- unit test
    -- use "vim-test/vim-test"
    use "nvim-neotest/neotest-go"
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/neotest-go",
        }
    }

    -- dashboard
    use "goolord/alpha-nvim"
    use "Shatur/neovim-session-manager"

    -- outline
    use "stevearc/aerial.nvim"
    use "tpope/vim-surround"
    use "norcalli/nvim-colorizer.lua"

    -- notify
    -- use "rcarriga/nvim-notify"
    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
    }
    use "nvim-telescope/telescope-ui-select.nvim"
end)
