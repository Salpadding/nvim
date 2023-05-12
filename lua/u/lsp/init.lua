local ok, ins, cmp_nvim_lsp
ok, _ = pcall(require, "lspconfig")
if not ok then
    print("lspconfig not installed")
    return
end


ok, ins = pcall(require, "nvim-lsp-installer")

if not ok then
    print("lsp installer not installed")
    return
end

-- setup lsp diagnostic
require "u.lsp.signs"

-- setup lsp installer, lazy load language server
local on_attach = function(client, bufnr)
    local mp = vim.api.nvim_buf_set_keymap
    local keys = require("u.lsp.keys")

    for name, v in pairs(keys) do
        local opts = { noremap = true, silent = true, desc = name }
        mp(bufnr, "n", v[1], string.format('<cmd>lua require("u.lsp.keys")["%s"][2]()<cr>', name), opts)
    end

    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.document_highlight then
        vim.cmd
        [[
              augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]]
    end
end

-- setup capabilities
local capabilities

ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
    capabilities = cmp_nvim_lsp.default_capabilities()
else
    print("cmp_nvim_lsp not installed")
end


-- lsp installer 懒加载
local on_server_ready = function(s)
-- 加载配置 u/lsp/settings/xxx.lua
    local o, opts = pcall(require, "u.lsp.settings." .. s.name)
    if not o then
        opts = {}
    end

    local fn = on_attach
    if opts.on_attach then
        local sub = opts.on_attach
        -- client, bufnr
        fn = function(c, b)
            sub(c, b)
            on_attach(c, b)
        end
    end
    opts.on_attach = fn
    opts.capabilities = capabilities
    s:setup(opts)
end

ins.on_server_ready(
    on_server_ready
)

local add_lsp = function(s)
    local o = {
        setup = function(this, opts)
            s.setup(opts)
        end,
        name = s.name,
    }
    on_server_ready(o)
end

add_lsp(require 'lspconfig'.ccls)
add_lsp(require 'lspconfig'.gopls)
add_lsp(require 'lspconfig'.rust_analyzer)
add_lsp(require 'lspconfig'.lua_ls)
add_lsp(require 'lspconfig'.pyright)

-- setup null-ls
require "u.lsp.nl"
