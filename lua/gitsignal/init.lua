local M = {}

local function truncate_path(full_path)
    -- Ensure that full_path is a string
    if type(full_path) ~= "string" then return "" end

    -- Get the directory and filename
    local dir, filename = full_path:match("(.*/)(.*)")
    
    -- If dir is nil, just return the full path
    if not dir then return full_path end
    
    -- Return the last directory and the filename
    local last_dir = dir:match(".*/(.*)/")
    return (last_dir or "") .. "/" .. filename
end

-- Apply truncation before displaying
local function truncate_paths(files)
    local truncated_files = {}
    for _, file in ipairs(files) do
        table.insert(truncated_files, truncate_path(file))
    end
    return truncated_files
end

-- Function to get changed files since the last commit
M.get_changed_files = function()
    -- Get all modified, deleted, and untracked files
    local handle = io.popen("git status --porcelain")
    if not handle then return {} end
    local result = handle:read("*a")
    handle:close()

    -- Debugging: Print the raw result
    print("Git Command Output: ", result)

    local all_files = {}
    for line in string.gmatch(result, "[^\r\n]+") do
        -- Extract the file path from the git status output
        local file_path = line:match("^[ %?MADRCU]+(.+)$")
        if file_path then
            table.insert(all_files, file_path)
            print("Detected file change: ", file_path)
        end
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
    all_files = vim.tbl_extend("force", all_files, unsaved_files)
    
    -- Directly return the full file paths
    return all_files, unsaved_files -- Return both all files and unsaved files
end

-- Function to display changed files in a small window
M.show_changed_files = function()
    local files, unsaved_files = M.get_changed_files()

    if vim.tbl_isempty(files) then
        print("No changes since last commit.")
        return
    end

    -- Truncate file paths before displaying
    local truncated_files = truncate_paths(files)

    -- Get the editor's width and height
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Calculate window size based on content
    local win_width = 40
    local win_height = math.min(#truncated_files + 2, height - 4) -- limit height to avoid oversize
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

    -- Set the buffer content with the truncated file paths
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, truncated_files)

    -- Highlight unsaved files in red
    for i, file in ipairs(truncated_files) do
        if vim.tbl_contains(unsaved_files, file) then
            vim.api.nvim_buf_add_highlight(buf, -1, "Error", i - 1, 0, -1) -- highlight the line in red
        end
    end

    -- Optional: make the window closeable with `q`
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
end

return M
