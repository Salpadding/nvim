return {
    -- 根据文件名后缀动态生成帮助菜单
    helps = function()
        local ok, telescope = pcall(require, "telescope")
        if not ok then
            print("telescope not installed")
            return
        end
        local tt = require('telescope.themes')
        local tb = require("telescope.builtin")

        local tests = {
            { group = 'Vim-test', desc = 'toggle summary', fn = function()
                require("neotest").summary.toggle()
            end },
            { group = 'Vim-test', desc = 'debug nearest', fn = function()
                require("neotest").run.run({ strategy = "dap" })
            end },
            { group = 'Vim-test', desc = 'test nearest', fn = function()
                require("neotest").run.run()
            end },
        }

        local ret = {
            { group = 'Nvimtree', desc = 'locate current file', fn = function() vim.cmd("NvimTreeFindFile") end },
            { group = 'Gerrit', desc = 'pending reviews', fn = function()
                local sal = require("u.sal")
                sal.gerrit(tt.get_dropdown({ previewer = false }))
            end
            },
            { group = 'Dap', desc = 'configurations in .vscode/lanuch.json', fn = function()
                local dap = require("dap")
                dap.configurations = {}
                local vs = require("dap.ext.vscode")
                vs.load_launchjs()
                telescope.extensions.dap.configurations {}
            end },
            { group = 'Dap', desc = 'disconnect without terminate', fn = function()
                local dap = require("dap")
                dap.disconnect({ terminateDebuggee = false })
            end },
            { group = 'Dap', desc = 'disconnect and terminate', fn = function()
                local dap = require("dap")
                dap.disconnect({ terminateDebuggee = true })
            end },
            { group = 'Dap', desc = 'breakpoints', fn = function()
                telescope.extensions.dap.list_breakpoints {}
            end },
            { group = 'Git', desc = 'current file commits', fn = function() vim.cmd [[DiffviewFileHistory %]] end,
            },
            { group = 'Git', desc = 'diff changes', fn = function()
                local sal = require("u.sal")
                if not sal.isDir(".git") then
                    print("not a git repository")
                    return
                end

                local s = sal.shell("git status --porcelain")
                if s == nil or s == "" then
                    print("no changes")
                    return
                end
                vim.api.nvim_command [[DiffviewOpen]]
            end,
            },
            -- { group = 'Git', desc = 'diff head with history commit', fn = function()
            --     local sal = require("u.sal")
            --     sal.diff(tt.get_dropdown({}, "head"))
            -- end,
            -- },
            { group = 'Git', desc = 'expand commit modifications', fn = function()
                local sal = require("u.sal")
                sal.diff(tt.get_dropdown({}, "."))
            end,
            },
            { group = 'Finder', desc = 'show all diagnostics', fn = function()
                tb.diagnostics({ layout_config = { width = 0.99 } })
            end
            },
            { group = 'Outline', desc = 'toggle outline', fn = function()
                vim.cmd [[AerialToggle right]]
            end
            },
        }
        local hasSuffix = function(s, suffix)
            return suffix == "" or s:sub(- #suffix) == suffix
        end

        local file = vim.fn.expand("%")
        if hasSuffix(file, ".go") and not hasSuffix(file, "_test.go") then
            return ret
        end


        for _, v in ipairs(tests) do
            ret[#ret + 1] = v
        end
        return ret
    end,
    -- 固定的 key map
    fixed = function()
        local cwd = "."
        local tb = require('telescope.builtin')
        local tt = require('telescope.themes')
        local t = "Finder"

        return {
            { key = "<leader>p", fn = function()
                tb.find_files(tt.get_dropdown({
                    cwd = cwd,
                    previewer = false
                }))
            end, group = t, desc = "find source files" },

            { key = "<leader>P", fn = function()
                tb.find_files(tt.get_dropdown({
                    cwd = cwd,
                    previewer = false,
                    no_ignore = true,
                    hidden = true,
                }))
            end, group = t, desc = "find all files" },

            { key = "<leader>f", fn = function()
                tb.live_grep({ layout_config = { width = 0.99 } })
            end, group = t, desc = "live grep source" },

            { key = "<leader>F", fn = function()
                tb.live_grep(
                    {
                    layout_config = { width = 0.99 },
                    additional_args = function() return { "--no-ignore", "--hidden" } end
                }
                )
            end, group = t, desc = "live grep all" },
        }
    end,

    -- 根据文件类型动态生成 which key
    random = function()
        return {
            { group = 'Finder', desc = 'resume', fn = function()
                vim.cmd [[Telescope resume]]
            end
            }
        }
    end
}
