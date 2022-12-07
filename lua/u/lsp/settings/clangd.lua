local opts = {
    on_attach = function(client)
        client.stop()
    end
}
return opts
