local M = {}

local function truncate_path(full_path)
    if type(full_path) ~= "string" then return "" end
    local dir, filename = full_path:match("(.*/)(.*)")
    if not dir then return full_path end
    local last_dir = dir:match(".*/(.*)/")
    return (last_dir or "") .. "/" .. filename
end

-- Function to get unsaved files in Neovim
M.get_unsaved_files = function()
    local unsaved_files = {}

    -- Check for unsaved files in Neovim
    for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
        local filename = vim.api.nvim_buf_get_name(buf_id)
        if filename and filename ~= "" then
            local is_modified = vim.api.nvim_buf_get_option(buf_id, "modified")
            if is_modified then
                table.insert(unsaved_files, filename)
            end
        end
    end

    return unsaved_files
end

-- Function to display unsaved files in a small window
M.show_unsaved_files = function()
    local unsaved_files = M.get_unsaved_files()

    -- Centered title for the floating window
    local title = " Git Signal "
    local truncated_files = {}
    for _, file in ipairs(unsaved_files) do
        table.insert(truncated_files, truncate_path(file))
    end

    -- Calculate window size and position based on the number of files
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_width = 40
    local win_height = math.max(#truncated_files + 2, 3) -- minimum height of 3 (title + 2 empty lines)
    local row = height - win_height - 4 -- slightly above lualine
    local col = width - win_width - 2

    -- Set up highlight groups
    vim.api.nvim_set_hl(0, "GitSignalNormalFloat", { bg = "NONE", fg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignalFloatBorder", { bg = "NONE", fg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignalUnsaved", { fg = "#e06c75", bold = true })

    -- Create a new floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = 'single',
        title = title,
        title_pos = 'center'
    })

    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:GitSignalNormalFloat,FloatBorder:GitSignalFloatBorder")

    if vim.tbl_isempty(truncated_files) then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "No unsaved files" })
    else
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, truncated_files)

        -- Highlight unsaved files in red
        for i, _ in ipairs(truncated_files) do
            vim.api.nvim_buf_add_highlight(buf, -1, "GitSignalUnsaved", i, 0, -1)
        end
    end

    -- Make the window closeable with a command
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', { noremap = true, silent = true })

    -- Store the buffer and window ID for later reference
    M.buf = buf
    M.win = win
end

-- Function to close the floating window
M.close_git_signal = function()
    if M.win and vim.api.nvim_win_is_valid(M.win) then
        vim.api.nvim_win_close(M.win, true)
    end
end

-- Register the commands globally
vim.cmd('delcommand Gitsignal')  -- Ensure no old command exists
vim.api.nvim_create_user_command('Gitsignal', M.show_unsaved_files, {})
vim.api.nvim_create_user_command('CloseGitsignal', M.close_git_signal, {})

-- Automatically show the floating window when Neovim starts
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        require('gitsignal').show_unsaved_files()
    end,
})

return M
