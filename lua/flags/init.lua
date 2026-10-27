local M = {}

local flag = require("flags.flag")
local keybinds = require("flags.keybinds")
local state = require("flags.state")
local config = require("flags.config")


function M.setup(user_config)
    local settings = config.setup(user_config or {})
    state.config = settings

    M.setup_rendering()
    state.flags = flag.load()

    keybinds.create_keybinds()
    keybinds.update_jump_keybinds()
end

function M.setup_rendering()
    vim.api.nvim_set_hl(0, "FlagsSign", {
        fg = state.config.style.flag_colour,
        bold = true,
    })
end

return M
