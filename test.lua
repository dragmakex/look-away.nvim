-- Run: nvim --headless -u NONE --cmd 'set rtp+=.' -l test.lua
local got = {}
vim.notify = function(msg) got[#got + 1] = msg end
local la = require("look-away")
la.setup({ interval = 2, duration = 1 })
assert(la.status():match("^⏳"), la.status())
assert(vim.wait(3500, function() return #got == 2 end, 100), vim.inspect(got))
assert(got[1]:match("20 feet"), got[1])
assert(got[2]:match("Break over"), got[2])
la.now()
assert(la.status():match("^👀"), la.status())
assert(#vim.api.nvim_list_wins() == 1, "no overlay without block")
la.skip()
la.config.block = true
la.now()
assert(#vim.api.nvim_list_wins() == 2, "overlay opens with block")
assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false)):match("20 feet"), "overlay text")
la.skip()
assert(#vim.api.nvim_list_wins() == 1, "overlay closes on skip")
la.stop()
assert(la.status() == "")
print("ok")
