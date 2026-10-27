local M = {}

local ui = require("flags.ui")
local flag = require("flags.flag")

function M.create_keybinds(flags)
    vim.keymap.set("n", "<leader>fm", function ()
        ui.toggle_window(flags)
    end, {})

    vim.api.nvim_create_user_command("FlagInfo", function()
        for i, f in ipairs(flags) do
            print(i .. ": ", f.path, f.line)
        end
    end, {})

    vim.keymap.set("n", "<leader>F", function()
        local f = flag.create()
        for _, existing_flag in ipairs(flags) do
            if existing_flag.path == f.path and existing_flag.context.row == f.context.row then
                print("Flag already exists at this location.")
                return
            end
        end
        table.insert(flags, f)
        flag.render(flags)
        M.update_jump_keybinds(flags)
    end, { desc = "Create flag" })

    vim.keymap.set("n", "<leader>fd", function()
        flags = flag.delete(flags)
        flag.render(flags)
        M.update_jump_keybinds(flags)
    end, { desc = "Delete flag" })

    vim.api.nvim_create_user_command("Fwipe", function()
        flag.wipe(flags)
        flags = {}
        flag.render(flags)
    end, {})

    vim.keymap.set("n", "<leader>fW", function()
        flag.wipe(flags)
        flags = {}
        flag.render(flags)
    end, { desc = "Delete flag" })


    vim.api.nvim_create_autocmd("BufWrite", {
        pattern = "*",
        callback = function()
            flags = flag.save(flags)
        end,
    })
end

function M.update_jump_keybinds(flags)
    for i, f in ipairs(flags) do
        vim.keymap.set("n", "<leader>f" .. i, function()
            flag.jump(f)
        end)
    end
end

return M
