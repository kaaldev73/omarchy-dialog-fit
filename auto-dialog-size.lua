-- Generic fix for apps that open floating dialogs tiny (e.g. Blender's file browser, 320x240,
-- on native Wayland). Works for any app: when a floating window opens smaller than
-- MIN_W x MIN_H, grow it to a usable size and center it. Windows the user sized on purpose
-- are only touched at open time, never afterwards.
local MIN_W, MIN_H = 480, 360          -- "tiny" threshold (logical px)
local TARGET_W, TARGET_H = 0.6, 0.7    -- resulting size as a fraction of the monitor
local SETTLE_MS = 300                  -- wait for the app's own first size/rules to settle

-- Small floating windows that are small on purpose. Matched against the window class.
local SKIP = {
  "^org%.omarchy", "^omarchy", "^io%.github%.omnirename",
  "^polkit", "^pavucontrol", "^org%.pulseaudio", "^blueman", "^nm%-", "^org%.gnome%.Calculator",
  "^xdg%-desktop%-portal", "^waybar", "^rustdesk$",
}

local function skipped(class)
  for _, p in ipairs(SKIP) do
    if class:find(p) then return true end
  end
  return false
end

local function monitor_size()
  local ok, m = pcall(hl.get_active_monitor)
  if ok and m and m.width and m.height then
    local s = (m.scale and m.scale > 0) and m.scale or 1
    return m.width / s, m.height / s
  end
  return 1600, 900
end

hl.on("window.open", function(w)
  hl.timer(function()
    if not (w.mapped and w.floating) then return end
    if skipped(w.class or "") then return end
    if w.size.x >= MIN_W or w.size.y >= MIN_H then return end
    local mw, mh = monitor_size()
    hl.dispatch(hl.dsp.window.resize({ x = math.floor(mw * TARGET_W), y = math.floor(mh * TARGET_H), window = w }))
    hl.dispatch(hl.dsp.window.center({ window = w }))
  end, { timeout = SETTLE_MS, type = "oneshot" })
end)
