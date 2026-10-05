.pragma library

// Defaults (logical px). Skip entries are Lua-style-free JS regex sources matched against the window class.
var defaults = {
  minWidth: 480,
  minHeight: 360,
  targetWidth: 0.6,
  targetHeight: 0.7,
  skip: [
    "^org\\.omarchy", "^omarchy", "^io\\.github\\.omnirename",
    "^polkit", "^pavucontrol", "^org\\.pulseaudio", "^blueman", "^nm-",
    "^org\\.gnome\\.Calculator", "^xdg-desktop-portal", "^waybar", "^rustdesk$"
  ]
}

function isSkipped(cls, skip) {
  for (var i = 0; i < skip.length; i++)
    if (new RegExp(skip[i]).test(cls || "")) return true
  return false
}

// Returns {x, y, w, h} (global logical px) for a window that should be grown, else null.
function plan(client, monitor, cfg) {
  cfg = cfg || defaults
  if (!client || !monitor) return null
  if (!client.mapped || !client.floating) return null
  if (isSkipped(client.class, cfg.skip)) return null
  var cw = client.size[0], ch = client.size[1]
  if (cw >= cfg.minWidth || ch >= cfg.minHeight) return null
  var scale = monitor.scale > 0 ? monitor.scale : 1
  var mw = monitor.width / scale, mh = monitor.height / scale
  var w = Math.floor(mw * cfg.targetWidth), h = Math.floor(mh * cfg.targetHeight)
  return {
    w: w, h: h,
    x: Math.floor(monitor.x + (mw - w) / 2),
    y: Math.floor(monitor.y + (mh - h) / 2)
  }
}

// Lua-config dispatch strings (Hyprland >= 0.55) for one window address.
function luaCommands(address, p) {
  var win = 'window = "address:' + address + '"'
  return [
    "hl.dsp.window.resize({ x = " + p.w + ", y = " + p.h + ", " + win + " })",
    "hl.dsp.window.move({ x = " + p.x + ", y = " + p.y + ", " + win + " })"
  ]
}

if (typeof module !== "undefined") module.exports = { plan: plan, luaCommands: luaCommands, defaults: defaults, isSkipped: isSkipped }
