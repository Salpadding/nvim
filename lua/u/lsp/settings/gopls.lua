local lsp = require('lspconfig')

local go_root_pattern = lsp.util.root_pattern(".git", "go.mod")

local opts = {
    on_attach = function(c, _)
        c.server_capabilities.document_formatting = false
        c.server_capabilities.document_range_formatting = false
    end,

    root_dir = function(startpath)
        -- vendor 忽略 go.mod 和 .git
        local vendor = vim.fn.getcwd() .. '/vendor'

        if string.sub(startpath, 0, #vendor) == vendor then
            return vim.fn.getcwd()
        end
        return go_root_pattern(startpath)
    end
}
return opts
