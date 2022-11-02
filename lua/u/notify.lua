local ok, n = pcall(require, "notify")

if not ok then
    print("notify not installed")
    return
end

n.setup({
    background_color = '#000000'
})
