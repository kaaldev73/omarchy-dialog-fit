-- Omarchy app fixes: per-app Hyprland window rules for apps with Wayland quirks.
-- Add a new app by adding one o.window(...) entry below.


-- Generic: any floating dialog that opens tiny gets a usable size (works for every app).
require("hypr.auto-dialog-size")
-- Opaque, non-blurred Unreal/Blender windows (undo Omarchy's global default opacity).
o.window({ class = "^(UnrealEditor|blender)$" }, { opacity = "1 1", no_blur = true })

-- Blender's file browser popup opens at 320x240 on native Wayland; give it a usable size.
-- (Redundant when Blender runs via XWayland, see blender.desktop override; kept as a fallback.)
o.window(
  { class = "^blender$", title = "^(File Browser|Blender File View)$" },
  { float = true, center = true, size = { "(monitor_w*0.6)", "(monitor_h*0.7)" } }
)
