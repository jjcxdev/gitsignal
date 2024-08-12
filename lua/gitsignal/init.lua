local M = {}
--Test
M.get_changed_files = function()
    -- Get changed files from git
    local handle = io.popen("git --porcelain")
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
    for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
        local filename = vim.api.nvim_buf_get_name(buf_id)
        
        -- Ensure the buffer has a valid name (i.e., it's associated with a file)
        if filename and filename ~= "" then
            local is_modified = vim.api.nvim_buf_get_option(buf_id, "modified")
            -- Debugging: Print buffer information
            print("Buffer ID:", buf_id, "Filename:", filename, "Modified:", is_modified)
            
            if is_modified then
                table.insert(unsaved_files, filename)
                print("Unsaved file detected: ", filename)
            end
        end
    end

    -- Combine and return both lists
    local all_files = vim.tbl_extend("force", git_files, unsaved_files)
    
    -- Directly return the full file paths
    return all_files
end

-- Function to display changed files in a small window
M.show_changed_files = function()
    local files = M.get_changed_files()

    if vim.tbl_isempty(files) then
        print("No changes since last commit.")
        return
    end

    -- Ensure files are printed out for debugging
    print("Files to display:", vim.inspect(files))

    -- Get the editor's width and height
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Calculate window size based on content
    local win_width = 40
    local win_height = math.min(#files + 2, height - 4) -- limit height to avoid oversize
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

    -- Apply terminal color scheme to avoid black spacing
    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:Normal,FloatBorder:FloatBorder")

    -- Set the buffer content with the full file paths
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)

    -- Optional: make the window closeable with `q`
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
end

return M
