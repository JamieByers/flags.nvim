local M = {}

function M.save_flags(flags)
    local cwd = vim.loop.cwd()
    M.update_wd_file({ [cwd] = flags })
end

function M.wipe_all_flags()
    local flags_data = M.get_flags_data()
    local cwd = vim.loop.cwd()

    if cwd and flags_data[cwd] then
        flags_data[cwd] = {}
        M.update_wd_file(flags_data)
    else
        error("no flags for current working directory")
    end
end

function M.add_flag_to_data(flag)
    flag = {
        path = flag.path,
        line = flag.context.row,
    }

    local flags_data = M.get_flags_data()
    local cwd = vim.loop.cwd()

    local flags = flags_data[cwd]

    for _, existing_flag in ipairs(flags) do
        if existing_flag.path == flag.path and existing_flag.line == flag.line then
            print("Flag already exists for this file")
            return
        end
    end

    table.insert(flags_data[cwd], flag)
    M.update_wd_file(flags_data)
end

function M.delete_flag_from_data(flag)
    flag = {
        path = flag.path,
        line = flag.context.row,
    }

    local flags_data = M.get_flags_data()
    local cwd = vim.loop.cwd()

    local flags = flags_data[cwd]
    for i, existing_flag in ipairs(flags) do
        if existing_flag.path == flag.path and existing_flag.line == flag.line then
            table.remove(flags, i)
            M.update_wd_file(flags_data)
            return
        end
    end

    print("Flag not found for this file")
end

function M.update_wd_file(flags)
    local wd = M.get_hashed_filepath()

    local flags_json = vim.fn.json_encode(flags)
    vim.fn.writefile({ flags_json }, wd)
end

function M.get_flags()
    local flags_data = M.get_flags_data()
    local cwd = vim.loop.cwd()

    local flags = flags_data[cwd]
    if not flags then
        return {}
    end

    return flags
end

function M.get_flags_data()
    if M.check_for_wd() then
        local lines = vim.fn.readfile(M.get_hashed_filepath())
        local content = table.concat(lines, "\n")
        local flag_data = vim.json.decode(content)
        return flag_data
    else
        local flag_data = { [vim.loop.cwd()] = {} }
        M.update_wd_file(flag_data)
        return flag_data
    end
end

function M.check_for_wd()
    local data_path = M.get_data_path()
    vim.fn.mkdir(data_path, "p")

    return vim.fn.filereadable(M.get_hashed_filepath()) == 1
end

function M.get_hashed_filepath()
    return M.get_data_path() .. "/" .. M.get_hashed_wd() .. ".json"
end

function M.get_data_path()
    local data_path = vim.fn.stdpath("data")
    if not data_path or data_path == "" then
        error("Failed to get data path")
    end
    return data_path .. "/flags"
end

function M.get_hashed_wd()
    local cwd = vim.loop.cwd()
    if cwd then
        return vim.fn.sha256(cwd)
    else
        error("Failed to get current working directory")
    end
end

return M
