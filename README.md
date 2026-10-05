# omarchy-wayland-app-fixes

Fixes for apps that misbehave on Omarchy (Hyprland, native Wayland). Not a shell plugin:
it is a Hyprland Lua module plus a small installer.

| Problem | Fix |
|---|---|
| Any app opens a floating dialog tiny (e.g. Blender's file browser at 320x240, [blender#162315](https://projects.blender.org/blender/blender/issues/162315)) | `auto-dialog-size.lua`: floating windows that open below 480x360 are grown to 60% x 70% of the screen and centered. Skip-list for windows that are small on purpose. |
| Blender file dialog | `blender.desktop` override launches Blender via XWayland (`WAYLAND_DISPLAY=`) |
| Unreal Editor popups/menus transparent or empty on native Wayland | `[Linux.SDL] VideoDriver=x11` in `LinuxEngine.ini`, re-applied by an Omarchy `post-update` hook |
| Omarchy's global ~0.96 opacity on Blender/Unreal | opaque rule in `app-fixes.lua` |

## Install / remove
```
UE_ROOT=/path/to/UnrealEngine ./apply-fix.sh   # UE_ROOT optional; omit to skip Unreal
./restore-original.sh
```
Safe to re-run. Backs up `~/.config/hypr/hyprland.lua` and the Unreal ini. Review the
scripts before running: they edit your Hyprland config and, if you set UE_ROOT, an engine file.

## Limits
Each app's bug is separate. This does not fix bugs inside apps (e.g. Unreal's native Wayland
rendering), nor cursor-lock/trapped-mouse issues. Tested on Hyprland 0.56.2, Omarchy, Blender 5.2, UE 5.8.

To handle another app, add an `o.window({ class = "^app$" }, { ... })` entry to `app-fixes.lua`.
