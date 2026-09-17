-- look-away.nvim: 20-20-20 rule reminders.
local M = {}

M.config = {
  interval = 20 * 60, -- seconds of work between breaks
  duration = 20,      -- seconds per break
  block = false,      -- cover the editor during breaks (<Esc> ends early)
}

local timer, state, remaining, win, buf

local function notify(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "Look Away" })
end

local function close()
  if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  win = nil
end

local function draw()
  if not M.config.block or state ~= "break" then return end
  if not (win and vim.api.nvim_win_is_valid(win)) then
    buf = vim.api.nvim_create_buf(false, true)
    win = vim.api.nvim_open_win(buf, true, {
      relative = "editor", row = 0, col = 0, zindex = 200,
      width = vim.o.columns, height = vim.o.lines, style = "minimal",
    })
    vim.keymap.set("n", "<Esc>", M.skip, { buffer = buf })
  end
  local msg = ("Look at something ~20 feet away  (%d)"):format(remaining)
  local lines = {}
  for _ = 1, math.floor(vim.o.lines / 2) do lines[#lines + 1] = "" end
  lines[#lines + 1] = string.rep(" ", math.floor((vim.o.columns - #msg) / 2)) .. msg
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local function switch(s)
  state, remaining = s, s == "break" and M.config.duration or M.config.interval
  if s == "break" then
    notify(("Look at something ~20 feet away for %d seconds."):format(remaining))
  else
    close()
    notify("Break over.")
  end
  draw()
end

local function tick()
  remaining = remaining - 1
  if remaining > 0 then return draw() end
  switch(state == "work" and "break" or "work")
end

function M.start()
  if timer then return end
  state, remaining = "work", M.config.interval
  timer = vim.uv.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(tick))
end

function M.stop()
  if not timer then return end
  timer:stop()
  timer:close()
  timer = nil
  close()
end

function M.toggle()
  if timer then M.stop() else M.start() end
end

-- Start a break right now.
function M.now()
  if not timer then M.start() end
  switch("break")
end

-- End the current break early.
function M.skip()
  if state == "break" then switch("work") end
end

-- For your statusline: "" when stopped, else "⏳ 12:34" (work) or "👀 0:15" (break).
function M.status()
  if not timer then return "" end
  local icon = state == "break" and "👀" or "⏳"
  return ("%s %d:%02d"):format(icon, math.floor(remaining / 60), remaining % 60)
end

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
  vim.api.nvim_create_user_command("LookAway", function(a)
    local cmd = a.args ~= "" and a.args or "toggle"
    if cmd == "status" then return notify(timer and M.status() or "stopped") end
    local fn = M[cmd] or M.toggle
    fn()
  end, {
    nargs = "?",
    complete = function() return { "start", "stop", "toggle", "now", "skip", "status" } end,
  })
  M.start()
end

return M
