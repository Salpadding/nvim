local ok, tree = pcall(require, 'nvim-tree')

if not ok then
    print("nvim-tree not installed")
    return
end

local defaultSize = 20

local custom = function()
    return {
        hijack_netrw = false,
        diagnostics = {
            enable = true,
            show_on_dirs = true,
        },
        git = {
            enable = true,
            ignore = false,
        },
        view = {
            width = defaultSize,
        },
        actions = {
            change_dir = {
                enable = false
            },
            open_file = {
                resize_window = false
            }
        },
        on_attach = function(bufnr)
            local api = require('nvim-tree.api')
            local function opts(desc)
                return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
            end

            vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
            vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
        end,
        renderer = {
            icons = {
                glyphs = {
                    default = "",
                    symlink = "",
                    git = {
                        unstaged = "",
                        staged = "",
                        unmerged = "",
                        renamed = "➜",
                        deleted = "",
                        untracked = "◍",
                        ignored = "◌",
                    },
                    folder = {
                        default = "",
                        open = "",
                        empty = "",
                        empty_open = "",
                        symlink = "",
                    },
                }
            }
        }
    }
end

tree.setup(custom())
