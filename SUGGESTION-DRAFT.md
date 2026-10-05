# DRAFT (not posted): Suggestion for basecamp/omarchy discussions

**Title:** Default rule: grow floating windows that open tiny (Blender file browser opens at 320x240)

**Problem**
On native Wayland, Blender opens its file browser ("Blender File View") at exactly 320x240,
ignoring its stored size (upstream: https://projects.blender.org/blender/blender/issues/162315,
still open). The dialog is unusable until resized by hand. Other apps that open dialogs with only a
minimum size set can behave the same way under Hyprland.

**Suggestion**
Add a small default to Omarchy's window handling: when a floating window opens smaller than
~480x360, resize it to ~60% x 70% of the monitor and center it, with a skip-list for windows
that are small on purpose (Omarchy's own dialogs, polkit, mixers, etc.).

Working Lua implementation (uses `hl.on("window.open")`, tested on Hyprland 0.56.2 / Omarchy):
https://github.com/kaaldev73/omarchy-wayland-app-fixes/blob/main/auto-dialog-size.lua

**Caveats**
- Heuristic: a legitimately tiny floating window not in the skip-list would be enlarged.
- Does not address app-side rendering bugs (e.g. Unreal Editor popups transparent/empty on native
  Wayland; workaround is `[Linux.SDL] VideoDriver=x11`).

(Repo link above works only once the repo is public.)
