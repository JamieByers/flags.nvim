local M = {}

local data = require("flags.data")

local NAMESPACE = vim.api.nvim_create_namespace('flags')


function M.jump(flag)
    local bufn = vim.fn.bufnr(flag.path, true)
    vim.api.nvim_set_current_buf(bufn)
    vim.api.nvim_win_set_cursor(0, { flag.context.row, flag.context.col })
end

function M.create(path, pos)
    local add_to_data = false
    if not path and not pos then
        add_to_data = true
    end

    path = path or vim.api.nvim_buf_get_name(0)
    pos = pos or vim.api.nvim_win_get_cursor(0)

    local bufnr = vim.fn.bufnr(path, true)
    vim.fn.bufload(bufnr)

    local row = pos[1]
    local id = vim.api.nvim_buf_set_extmark(bufnr, NAMESPACE, row-1, 0, {})

    local flag = {
        path = path,
        id = id,
        bufnr = bufnr,
        context = {
            row = row,
            col = 0
        }
    }

    if add_to_data then
        data.add_flag_to_data(flag)
    end

    return flag
end

function M.load()
    local flags = data.get_flags()

    for i, flag in ipairs(flags) do
        flags[i] = M.create(flag.path, { flag.line, 0 })
    end

    M.render(flags)

    return flags
end

function M.render(flags)
    for i, flag in ipairs(flags) do
        local id = flag.id
        local bufnr = flag.bufnr

        local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, NAMESPACE, id, {})

        local text = i .. '⚑'
        if i > 9 then
            text = tostring(i)
        end

        if #pos > 0 then
            vim.api.nvim_buf_set_extmark(bufnr, NAMESPACE, pos[1], pos[2], {
                id = id,
                sign_text = text,
                sign_hl_group = "DiagnosticSignError",
            })
        end
    end
end

function M.save(flags)
    local new_flags = {}
    for i, flag in ipairs(flags) do
        local pos = vim.api.nvim_buf_get_extmark_by_id(flag.bufnr, NAMESPACE, flag.id, {})
        if #pos > 0 then
            local f = {
                path = flag.path,
                line = pos[1]+1
            }
            flags[i].context.row = pos[1]+1
            table.insert(new_flags, f)
        end
    end

    data.save_flags(new_flags)
    return flags
end

function M.wipe(flags)
    for _, flag in ipairs(flags) do
        vim.api.nvim_buf_del_extmark(flag.bufnr, NAMESPACE, flag.id)
    end
    data.wipe_all_flags()
end

function M.delete(flags)
    local bufnr = vim.api.nvim_get_current_buf()
    local pos = vim.api.nvim_win_get_cursor(0)
    local new_flags = {}

    for _, flag in ipairs(flags) do
        local flag_pos = vim.api.nvim_buf_get_extmark_by_id(
            flag.bufnr,
            NAMESPACE,
            flag.id,
            {}
        )

        if flag.bufnr == bufnr
            and #flag_pos > 0
            and flag_pos[1] == pos[1] - 1 then

            vim.api.nvim_buf_del_extmark(
                flag.bufnr,
                NAMESPACE,
                flag.id
            )

            data.delete_flag_from_data(flag)
        else
            table.insert(new_flags, flag)
        end
    end

    return new_flags
end
return M
