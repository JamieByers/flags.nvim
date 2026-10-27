# flags.nvim

Simple persistent file and line markers for Neovim.

Flags are attached to buffers with extmarks, so they follow their line when
text is inserted or deleted. They can be displayed in a floating window and
jumped to with numbered mappings.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "JamieByers/flags.nvim",
    config = function()
        require("flags").setup()
    end,
}
```

For local development:

```lua
{
    dir = "/path/to/flags.nvim",
    name = "flags",
    config = function()
        require("flags").setup()
    end,
}
```

## Configuration

The following is all configurable settings for the plugin.
The example uses the plugin defaults to show how to configure the plugin, but you can change any of the values to a value you prefer.

```lua
require("flags").setup({
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
    },
})
```

For example:

```lua
require("flags").setup({
    keybinds = {
        toggle_window = "<leader>fw",
        create_flag = "<leader>fc",
    },
    style = {
        flag_symbol = "●",
        flag_colour = "#89b4fa",
    },
})
```

`flag_symbol` must contain one character. `jump_prefix` is followed by the
flag number, so the first flag uses `<leader>f1`.

The flags are displayed as `<FlagIndex><FlagSymbol>`

## Usage

Global mappings:

| Mapping | Action |
| --- | --- |
| `<leader>F` | Create a flag at the cursor |
| `<leader>fd` | Delete the flag at the cursor |
| `<leader>fW` | Delete all flags |
| `<leader>fm` | Toggle the flags window |
| `<leader>f1`, `<leader>f2`, ... | Jump directly to a flag |


Inside the flags window:

| Mapping | Action |
| --- | --- |
| `q` or `<Esc>` | Close the window |
| `dd` | Delete the selected flag |
| `<CR>` | Jump to the selected flag |

The `WipeFlags` user command also deletes all flags:

```vim
:WipeFlags
```

## Persistence

Flags are stored per working directory under Neovim's data directory. The
stored path and line are loaded when the plugin starts. Extmarks keep the
in-memory location synchronized as buffers change, and flags are saved on
`BufWrite`.

You can find the in-memory locally at the path "/Users/YOUR_USERNAME/.local/share/nvim/flags".

They are stored in a JSON file named after the hashed working directory, with the path and line of each flag.
