local ok, autosave = pcall(require, "auto-save")


if not ok then
    print("autosave not installed")
    return
end

autosave.setup(
    {
    enabled = true,
    execution_message = {
        message = function() return "" end,
    },
    trigger_events = { "InsertLeave", "TextChanged" },
    write_all_buffers = false,
    debounce_delay = 200
}
)
