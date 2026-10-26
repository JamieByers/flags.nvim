local M = {}

local NAMESPACE = vim.api.nvim_create_namespace('flags')

function M.renderExtmarks(flags)
    flags = M.load_buffers(flags) or {}

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

function M.load_buffers(flags)
    for _, flag in ipairs(flags) do
        local bufnr = vim.fn.bufadd(flag.path)
        vim.fn.bufload(bufnr)
        flag.bufnr = bufnr
    end

    return flags
end

function M.add_flag(flag, flags)
    table.insert(flags, flag)
end

function M.jump_to_flag(flag)
    local bufn = vim.fn.bufnr(flag.path, true)
    vim.api.nvim_set_current_buf(bufn)
    vim.api.nvim_win_set_cursor(0, { flag.context.row, flag.context.col })
end

function M.create_flag(path, row)
    local bufnr = vim.fn.bufadd(path)
    local id = vim.api.nvim_buf_set_extmark(bufnr, NAMESPACE, row-1, 0, {})

    return {
        path = path,
        id = id,
        bufnr = bufnr,
        context = {
            row = row,
            col = 0
        }
    }
end

function M.load_flags(flags)
    for i, flag in ipairs(flags) do
        flags[i] = M.create_flag(
            flag.path,
            flag.context.row
        )
    end

    return flags
end

return M
