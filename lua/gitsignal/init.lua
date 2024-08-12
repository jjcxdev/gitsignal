local M = {}

local function truncate_path(full_path)
    if type(full_path) ~= "string" then return "" end
    local dir, filename = full_path:match("(.*/)(.*)")
    if not dir then return full_path end
    local last_dir = dir:match(".*/(.*)/")
    return (last_dir or "") .. "/" .. filename
end

-- Function to get new and modified files
M.get_changed_files = function()
    local handle = io.popen("git status --porcelain")
    if not handle then return {}, {} end
    local result = handle:read("*a")
    handle:close()

    local all_files = {}
    local unsaved_files = {}

    -- Process git status output for new and modified files
    for line in string.gmatch(result, "[^\r\n]+") do
        local status = line:sub(1, 2):gsub("%s", "")
        local file_path = line:match("^%s*[MADRCU?]+%s+(.+)$")

        if file_path then
            if status == "M" or status == "??" then
                table.insert(all_files, file_path)
            end
        end
    end

    -- Check for unsaved files in Neovim
    for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
        local filename = vim.api.nvim_buf_get_name(buf_id)
        if filename and filename ~= "" then
            local is_modified = vim.api.nvim_buf_get_option(buf_id, "modified")
            if is_modified then
                -- Add the unsaved file to both the unsaved list and the main list with a marker
                table.insert(unsaved_files, filename)
                table.insert(all_files, "* " .. filename)
            end
        end
    end

    return all_files, unsaved_files
end

-- Function to display changed files in a small window
M.show_changed_files = function()
    local files, _ = M.get_changed_files()

    if vim.tbl_isempty(files) then
        print("No changes since last commit.")
        return
    end

    local truncated_files = {}
    for _, file in ipairs(files) do
        if file:find("^* ") then
            table.insert(truncated_files, "* " .. truncate_path(file:sub(3)))
        else
            table.insert(truncated_files, truncate_path(file))
        end
    end

    -- Get the editor's width and height
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_width = 40
    local win_height = math.min(#truncated_files + 2, height - 4)
    local row = height - win_height - 2
    local col = width - win_width - 2

    -- Set up highlight groups to be transparent
    vim.api.nvim_set_hl(0, "GitSignalNormalFloat", { bg = "NONE", fg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignalFloatBorder", { bg = "NONE", fg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignalUnsaved", { fg = "#e06c75", bold = true })

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = 'single'
    })

    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:GitSignalNormalFloat,FloatBorder:GitSignalFloatBorder")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, truncated_files)

    -- Highlight unsaved files in red and add markers
    for i, file in ipairs(truncated_files) do
        if file:find("^* ") then
            vim.api.nvim_buf_add_highlight(buf, -1, "GitSignalUnsaved", i - 1, 0, -1)
        end
    end

    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
end

return M
