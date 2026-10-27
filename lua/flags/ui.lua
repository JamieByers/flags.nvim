local M = {}

local window_id = nil

function M.close_window()
    if window_id and vim.api.nvim_win_is_valid(window_id) then
        vim.api.nvim_win_close(window_id, true)
        window_id = nil
    end
end

function M.create_window(flags)
    local lines = M.create_flag_lines(flags)

    local buf = vim.api.nvim_create_buf(false, true)

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local window_config = {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        title = " Flags ",
        title_pos = "center",
    }


    vim.api.nvim_buf_set_lines(buf, 0, #lines+1, false, lines)

    window_id = vim.api.nvim_open_win(buf, true, window_config)
    vim.api.nvim_set_option_value(
        "winhl",
        "Normal:Normal,FloatBorder:FlagsWindow",
        { win = window_id }
    )

    return buf, window_id
end

function M.create_flag_lines(flags)
    local lines = {}

    for i, flag in ipairs(flags) do
        table.insert(lines, string.format("%s: %s line: %s", i, flag.path, flag.context.row))
    end

    return lines
end

function M.toggle_window(flags)
    if window_id and vim.api.nvim_win_is_valid(window_id) then
        M.close_window()
    else
        M.create_window(flags)
    end
end

return M

