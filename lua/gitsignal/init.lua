local M = {}

-- Function to get changed files since the last commit
M.get_changed_files = function()
    local handle = io.popen("git diff --name-only HEAD")
    if not handle then return {} end
    local result = handle:read("*a")
    handle:close()

    local files = {}
    for file in string.gmatch(result, "[^\r\n]+") do
        table.insert(files, file)
    end

    return files
end

-- Function to display changed files in a small window
M.show_changed_files = function()
    local files = M.get_changed_files()

    if vim.tbl_isempty(files) then
        print("No changes since last commit.")
        return
    end

    -- Create a new floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = 40,
        height = #files + 2,
        row = 3,
        col = 3,
        border = 'single'
    })

    -- Set the buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)

    -- Optional: make the window closeable with `q`
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
end

return M
