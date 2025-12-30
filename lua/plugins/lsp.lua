-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- because lsp config is moved to vim.lsp.config, we will leave a dummy dependency here, 
  -- so that lazy will not throw error
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    local cap = require("cmp_nvim_lsp").default_capabilities()

    -- 1) shared defaults for all servers
    vim.lsp.config("*", {
      capabilities = cap,
    })

    -- 2) per-server configs (new API)
    vim.lsp.config("lua_ls", {
      on_init = function(client)
        local wf = client.workspace_folders
        local path = wf and wf[1] and wf[1].name or nil
        if path
          and (vim.uv.fs_stat(path .. "/.luarc.json")
            or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
          runtime = { version = "LuaJIT" },
          workspace = {
            checkThirdParty = false,
            library = { vim.env.VIMRUNTIME },
          },
        })
      end,
      settings = { Lua = {} },
    })

    vim.lsp.config("pyright", {})
    vim.lsp.config("ts_ls", {})      -- typescript-language-server (renamed from tsserver upstream)
    vim.lsp.config("gopls", {})
    vim.lsp.config("ccls", { filetypes = { "c", "cpp" } })
    vim.lsp.config("ruby_lsp", {})

    -- 3) enable (auto-start on matching filetypes & root)
    vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "gopls", "ccls", "ruby_lsp" })
  end,
}
