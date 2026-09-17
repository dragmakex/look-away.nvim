# look-away.nvim

20-20-20 rule for Neovim: every 20 minutes, look at something ~20 feet away for 20 seconds.

## Install (lazy.nvim)

```lua
{ "dragmakex/look-away.nvim", opts = { interval = 20 * 60, duration = 20 } } -- seconds
```

## Commands

`:LookAway [start|stop|toggle|now|status]` — no arg toggles.

## Statusline

```lua
require("look-away").status() -- "⏳ 12:34" working, "👀 0:15" on break, "" stopped
```

## Test

```sh
nvim --headless -u NONE --cmd 'set rtp+=.' -l test.lua
```
