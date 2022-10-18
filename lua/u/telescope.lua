local ok, telescope = pcall(require, "telescope")
if not ok then
    print("telescope not installed")
    return
end

local actions = require "telescope.actions"

telescope.load_extension('dap')


telescope.setup({
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_cursor {
                previewer = false,
            }
        }
    },
    defaults = {
        mappings = {
            i = {
                ["<Tab>"] = actions.select_default,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<esc>"] = actions.close,
                ["<CR>"] = actions.select_default,
            }
        },
    }
})


telescope.load_extension("ui-select")


