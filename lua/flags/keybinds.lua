local M = {}

function M.create_keybinds()
    vim.api.nvim_create_user_command("RF", function()
        package.loaded["flags"] = nil
        require("flags").setup()
    end, {})

    vim.keymap.set("n", "<leader>F", function()
        package.loaded["flags"] = nil
        require("flags").setup()
        M.add_flag()
    end, { desc = "Create flag" })

    for i, flag in ipairs(flags or data.get_flags()) do
        local key = "<leader>f" .. i
        vim.keymap.set("n", key, function()
            mark.jump_to_flag(flag)
        end, { desc = "Jump to flag " .. i })
    end

end

return M
