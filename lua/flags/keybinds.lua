local M = {}

local ui = require("flags.ui")
local flag = require("flags.flag")
local state = require("flags.state")

local jump_prefix = "<leader>f"

function M.create_keybinds()
    jump_prefix = state.config.keybinds.jump_prefix or jump_prefix

    vim.keymap.set("n", state.config.keybinds.toggle_window, function ()
        ui.toggle_window()
    end, {})

    vim.keymap.set("n", "<leader>F", function()
        local f = flag.create()
        for _, existing_flag in ipairs(state.flags) do
            if existing_flag.path == f.path and existing_flag.context.row == f.context.row then
                print("Flag already exists at this location.")
                return
            end
        end
        table.insert(state.flags, f)
        M.refresh()
    end, { desc = "Create flag" })

    vim.keymap.set("n", state.config.keybinds.delete_flag, function()
        state.flags = flag.delete(state.flags)
        M.refresh()
    end, { desc = "Delete flag" })

    vim.api.nvim_create_user_command("WipeFlags", function()
        flag.wipe(state.flags)
        state.flags = {}
        M.refresh()
    end, {})

    vim.keymap.set("n", state.config.keybinds.wipe_flags, function()
        flag.wipe(state.flags)
        state.flags = {}
        M.refresh()
    end, { desc = "Delete flag" })


    vim.api.nvim_create_autocmd("BufWrite", {
        pattern = "*",
        callback = function()
            state.flags = flag.save(state.flags)
            M.refresh()
        end,
    })
end

function M.refresh()
    flag.render(state.flags)
    M.update_jump_keybinds()
end

function M.update_jump_keybinds()
    for i, f in ipairs(state.flags) do
        vim.keymap.set("n", jump_prefix .. i, function()
            flag.jump(f)
        end)
    end
end

return M
