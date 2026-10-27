local M = {}

local default_config = {
    keybinds = {
        toggle_window = "<leader>fm",
        create_flag = "<leader>F",
        delete_flag = "<leader>fd",
        wipe_flags = "<leader>fW",
        jump_prefix = "<leader>f",
    },

    style = {
        flag_symbol = "⚑",
        flag_colour = "#eb6f92",
    }

}

function M.validate_config(config)
    if #config.style.flag_symbol > 1 then
        vim.notify("Flag symbol must be a single character, reverting to default", vim.log.levels.WARN)
        config.style.flag_symbol = default_config.style.flag_symbol
    end

end

function M.merge_tables(config, default)
    for k, v in pairs(default) do
        if type(v) == "table" then
            if config[k] == nil then
                config[k] = {}
            end
            M.merge_tables(config[k], v)
        else
            if config[k] == nil then
                config[k] = v
            end
        end
    end
end

function M.setup(config)
    M.validate_config(config)
    M.merge_tables(config, default_config)
    return config
end

return M
