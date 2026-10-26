local M = {}

local flag_handler = require("flags.flag")
local data = require("flags.data")
local flags = {}


function M.setup()
    flags = data.get_flags()
    flag_handler.renderExtmarks(flags)

    M.create_keybinds()
end

function M.get_current_pos()
    local buf_name = vim.api.nvim_buf_get_name(0)
    local bufn = vim.fn.bufnr(buf_name, true)

    print(buf_name, bufn)
    return buf_name
end

function M.get_flag_at_cursor()
    local pos = vim.api.nvim_win_get_cursor(0)
    local row = pos[1]

    if not flags then
        return nil
    end

    for _, flag in ipairs(flags) do
        if flag.context.row == row then
            return flag
        end
    end

    return nil
end

function M.add_flag()
    local path = M.get_current_pos()
    local pos = vim.api.nvim_win_get_cursor(0)

    local flag = flag_handler.create_flag(path, pos[1])
    data.add_flag_to_data(flag)
    table.insert(flags, flag)
    data.save_flags(flags)
end

function M.refresh()
    data.save_flags(flags)
    flag_handler.renderExtmarks(flags)
end

function M.create_keybinds()
    vim.api.nvim_create_user_command("RF", function()
        M.refresh()
    end, {})

    vim.api.nvim_create_user_command("FlagInfo", function()
        for i, flag in ipairs(flags or data.get_flags()) do
            print(i .. ": ", flag.path, flag.line)
        end
    end, {})

    vim.api.nvim_create_user_command("FWipeFlags", function()
        data.wipe_all_flags()
        M.refresh()
    end, {})

    vim.keymap.set("n", "<leader>F", function()
        M.add_flag()
        M.refresh()
    end, { desc = "Create flag" })

    vim.keymap.set("n", "<leader>fd", function()
        local flag = M.get_flag_at_cursor()
        if flag then
            data.delete_flag_from_data(flag)
            M.refresh()
        else
            print("No flag at cursor position")
        end
    end, { desc = "Delete flag" })

    for i, flag in ipairs(flags or data.get_flags()) do
        local key = "<leader>f" .. i
        vim.keymap.set("n", key, function()
            flag_handler.jump_to_flag(flag)
        end, { desc = "Jump to flag " .. i })
    end

    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*",
        callback = function()
            M.refresh()
        end,
    })

    vim.api.nvim_create_autocmd("BufRead", {
        pattern = "*",
        callback = function()
            flags = flag_handler.load_flags(data.get_flags())
            flag_handler.renderExtmarks(flags)
        end,
    })
end

return M
