local M = {}

local flag = require("flags.flag")
local state = require("flags.state")

local window_id = nil
local window_bufn = nil

function M.close_window()
    if window_id and vim.api.nvim_win_is_valid(window_id) then
        vim.api.nvim_win_close(window_id, true)
        window_id = nil
        window_bufn = nil
    end
end

function M.create_window()
    local lines = M.create_flag_lines(state.flags)

    local buf = vim.api.nvim_create_buf(false, true)

    local width = math.floor(vim.o.columns * 0.75)
    local height = math.floor(vim.o.lines * 0.5)

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
    window_bufn = buf

    vim.api.nvim_set_option_value(
        "winhl",
        "Normal:Normal,FloatBorder:FlagsWindow",
        { win = window_id }
    )
    M.create_window_keybindings()

    return buf, window_id
end

function M.create_flag_lines(flags)
    local lines = {}

    for i, flag in ipairs(flags) do
        table.insert(lines, string.format("%s: %s line: %s", i, flag.path, flag.context.row))
    end

    return lines
end

function M.toggle_window()
    if window_id and vim.api.nvim_win_is_valid(window_id) then
        M.close_window()
    else
        M.create_window()
    end
end

function M.delete_flag()
    local index = vim.api.nvim_win_get_cursor(0)[1]
    if index <= #state.flags and window_bufn then
        state.flags = flag.delete(state.flags, index)
        flag.render(state.flags)
        vim.api.nvim_buf_set_lines(
            window_bufn,
            0,
            -1,
            false,
            M.create_flag_lines(state.flags)
        )
    end

    require("flags.keybinds").refresh()
end

function M.jump_to_flag()
    local index = vim.api.nvim_win_get_cursor(0)[1]
    if index <= #state.flags then
        local flag_to_jump = state.flags[index]
        if flag_to_jump then
            M.close_window()
            flag.jump(flag_to_jump)
        end
    end
end

function M.create_window_keybindings()
    if window_bufn == nil then
        return
    end

    local keybindings = {
        ["q"] = M.close_window,
        ["<Esc>"] = M.close_window,
        ["dd"] = M.delete_flag,
        ["<CR>"] = M.jump_to_flag,
    }

    for key, action in pairs(keybindings) do
        vim.api.nvim_buf_set_keymap(window_bufn, "n", key, "", {
            noremap = true,
            silent = true,
            callback = action,
        })
    end

end

return M
