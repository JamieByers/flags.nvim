local M = {}

local flag = require("flags.flag")
local keybinds = require("flags.keybinds")
local state = require("flags.state")

function M.setup()
    state.flags = flag.load()
    flag.render(state.flags)

    keybinds.create_keybinds()
    keybinds.update_jump_keybinds()
end

return M
