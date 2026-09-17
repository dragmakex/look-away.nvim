-- look-away.nvim: 20-20-20 rule reminders.
local M = {}

M.config = {
  interval = 20 * 60, -- seconds of work between breaks
  duration = 20,      -- seconds per break
}

local timer, state, remaining

local function notify(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "Look Away" })
end

local function tick()
  remaining = remaining - 1
  if remaining > 0 then return end
  if state == "work" then
    state, remaining = "break", M.config.duration
    notify(("Look at something ~20 feet away for %d seconds."):format(remaining))
  else
    state, remaining = "work", M.config.interval
    notify("Break over.")
  end
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
end

function M.toggle()
  if timer then M.stop() else M.start() end
end

-- Start a break right now.
function M.now()
  if not timer then M.start() end
  state, remaining = "work", 1
  tick()
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
    complete = function() return { "start", "stop", "toggle", "now", "status" } end,
  })
  M.start()
end

return M
