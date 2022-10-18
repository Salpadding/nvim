local opts = {
    on_attach = function(c, _)
        c.server_capabilities.document_formatting = false
        c.server_capabilities.document_range_formatting = false
    end,

}
return opts
