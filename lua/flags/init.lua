local M = {}

local flag = require("flags.flag")
local flags = {}

function M.setup()
    flags = flag.load()
    flag.render(flags)

    M.create_keybinds()
    M.update_jump_keybinds()
end

function M.create_keybinds()
    vim.api.nvim_create_user_command("FlagInfo", function()
        for i, f in ipairs(flags) do
            print(i .. ": ", f.path, f.line)
        end
    end, {})

    vim.keymap.set("n", "<leader>F", function()
        local f = flag.create()
        table.insert(flags, f)
        flag.render(flags)
        M.update_jump_keybinds()
    end, { desc = "Create flag" })

    vim.keymap.set("n", "<leader>fd", function()
        flags = flag.delete(flags)
        flag.render(flags)
        M.update_jump_keybinds()
    end, { desc = "Delete flag" })

    vim.api.nvim_create_user_command("Fwipe", function()
        flag.wipe(flags)
        flags = {}
        flag.render(flags)
    end, {})

    vim.api.nvim_create_autocmd("BufWrite", {
        pattern = "*",
        callback = function()
            flags = flag.save(flags)
        end,
    })
end

function M.update_jump_keybinds()
    for i, f in ipairs(flags) do
        vim.keymap.set("n", "<leader>f" .. i, function()
            flag.jump(f)
        end)
    end
end

return M
