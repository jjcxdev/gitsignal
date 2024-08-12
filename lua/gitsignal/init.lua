local M = {}

-- Function to truncate filepath in response
local function truncate_path(full_path)
    -- Get the directory and filename
    local dir, filename = full_path:match("(.*/)(.*)")
    -- Return the last directory and the filename
    if dir then
        local last_dir = dir:match(".*/(.*)/")
        return (last_dir or "") .. "/" .. filename
    else
        return full_path -- fallback if pattern doesn't match
    end
end

-- Function to apply truncation to all file paths in the list
local function truncate_paths(files)
    local truncated_files = {}
    for _, file in ipairs(files) do
        table.insert(truncated_files, truncate_path(files))
    end
    return truncated_files
end

-- Function to get changed files since the last commit
M.get_changed_files = function()

    -- Get changed files from git
    local handle = io.popen("git diff --name-only HEAD")
    if not handle then return {} end
    local result = handle:read("*a")
    handle:close()

    -- Debugging: Print the raw result
    print("Git Command Output: ", result)

    local git_files = {}
    for file in string.gmatch(result, "[^\r\n]+") do
        table.insert(git_files, file)
    end

    -- Get unsaved files from Neovim
    local unsaved_files = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_option(buf, "modified") then
            local filename = vim.api.nvim_buf_get_name(buf)
            table.insert(unsaved_files, filename)
            -- Debugging
            print("Unsaved file detected:", filename)
    end
end

    -- Combine and return both lists
    local all_files = vim.tbl_extend("force", git_files, unsaved_files)

    --Truncate the paths
    local truncated_files = truncate_paths(all_files)
    return truncated_files
end

-- Function to display changed files in a small window
M.show_changed_files = function()
    local files = M.get_changed_files()

    if vim.tbl_isempty(files) then
        print("No changes since last commit.")
        return
    end

    -- Get the editor' width and height
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Calcualte window size and position
    local win_width = 40
    local win_height = #files + 2
    local row = height - win_height - 2
    local col = width - win_width - 2

    -- Create a new floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = 'single'
    })

    -- Apply terminal color scheme
    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:Normal,FloatBorder:FloatBorder")

    -- Set the buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)

    -- Optional: make the window closeable with `q`
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
end

return M
