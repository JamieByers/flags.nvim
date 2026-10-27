local M = {}

local flag = require("flags.flag")
local keybinds = require("flags.keybinds")
local flags = {}

function M.setup()
    flags = flag.load()
    flag.render(flags)

    keybinds.create_keybinds(flags)
    keybinds.update_jump_keybinds(flags)
end

return M
