local actions = require "telescope.actions"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local action_state = require "telescope.actions.state"

-- 执行 shell 命令, 返回标准输出
local shell = function(s)
    local handle = io.popen(s)
    if handle == nil then
        return ""
    end
    local result = handle:read("*a")
    handle:close()
    return result
end

-- diff 生成 diff telescope
local diff = function(opts, src)
    local records = shell('git log --pretty=format:"%h %an %ar"'):gmatch("[^\r\n]+")
    local msgs = (function()
        local ms = shell('git log --pretty=format:"%s"'):gmatch("[^\r\n]+")
        local j = 1
        local ret = {}
        for s in ms do
            ret[j] = s
            j = j + 1
        end
        return ret
    end)()

    local es = {}
    local max = 0

    for s in records do
        es[#es + 1] = s
        max = math.max(max, #s)
    end

    local max1 = 0

    for i, v in ipairs(es) do
        local pad = max - #v
        es[i] = es[i] .. string.rep(' ', pad) .. ' - ' .. msgs[i]
        max1 = math.max(max1, #es[i])
    end

    if opts == nil then
        opts = {}
    end
    opts.previewer = false
    opts.layout_config = {
        height = math.min(#es + 4, vim.o.lines - 8),
        width = math.min(max1 + 8, vim.o.columns - 8)
    }
    pickers.new(opts, {
        prompt_title = "git commits",
        finder = finders.new_table {
            results = es
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local s = action_state.get_selected_entry()
                if s == nil then
                    return
                end
                -- commit hash
                local h = s[1]:match("^[0-9a-fA-F]+")

                if src == "head" then
                    vim.api.nvim_command(string.format(
                        "DiffviewOpen %s..HEAD", h
                    ))
                    return
                end

                local prev = es[#es]
                for i, v in ipairs(es) do
                    if v == s[1] and i < #es then
                        prev = es[i + 1]
                    end
                end

                prev = prev:match("^[0-9a-fA-F]+")
                local cmd = string.format(
                    "DiffviewOpen %s..%s", prev,h
                )
                print(cmd)
                vim.api.nvim_command(cmd)
            end)
            return true
        end,
    }):find()
end

-- TIPS: 使用 hammerspoon 实现剪贴板同步
if hs ~= nil then
    -- 以下代码加到 .hammerspoon/init.lua
    local cb = function(contents)
        local p = io.popen('ssh -o StrictHostKeyChecking=no arch@arch.rs "DISPLAY=:0 xsel -bi"', 'w')
        p:write(contents)
        p:close()
    end
    hs.pasteboard.watcher.new(cb)
end

local fns = {
    isDir = function(s)
        local fd = vim.loop.fs_open(s, "r", 438)
        if fd == nil then return false end
        local stat = assert(vim.loop.fs_fstat(fd))
        vim.loop.fs_close(fd)
        return stat.type == "directory"
    end,

    shell = shell,

    yank = function()
        local content = vim.fn.getreg('+')
        local handle = io.popen('/usr/bin/ssh -o StrictHostKeyChecking=no "sal@sal.rs" "LANG=en_US.UTF-8 pbcopy"', 'w')
        if handle == nil then
            return ""
        end
        handle:write(vim.fn.getreg('+'))
        handle:close()
    end,

    diff = diff,
    gerrit = function(opts)
        local result = shell("git review -l -r origin")

        local reviews = {}
        local i = 1
        if result:find('^No') == nil then
            for s in result:gmatch("[^\r\n]+") do
                if s:find('^Found') == nil then
                    reviews[i] = s
                    i = i + 1
                end
            end
        end

        pickers.new(opts, {
            prompt_title = "gerrit reviews",
            finder = finders.new_table {
                results = reviews
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection == nil then
                        return
                    end
                    local change = string.match(selection[1], '%d*')
                    os.execute('git review -d ' .. change .. ' -r origin')
                    local o, _ = pcall(require, "nvim-tree")
                    if o then
                        vim.cmd [[NvimTreeRefresh]]
                    end
                end)
                return true
            end,
        }):find()
    end,
}
function Sal(s)
    local fn = fns[s]
    if fn ~= nil then
        fn()
    end
end

return fns
