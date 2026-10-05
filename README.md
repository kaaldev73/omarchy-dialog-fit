# Dialog Fit — Omarchy shell plugin

Some apps open floating dialogs tiny under Hyprland on native Wayland. The classic case is
Blender's file browser, created at exactly 320x240 and ignoring its stored size
([blender#162315](https://projects.blender.org/blender/blender/issues/162315)).

**Dialog Fit** watches new windows. If a window opens floating and smaller than 480x360, it is grown
to 60% x 70% of its monitor and centered. It works for any app; no per-app rules.

## Install
```
omarchy plugin add https://github.com/kaaldev73/omarchy-dialog-fit.git --enable
```
Remove with `omarchy plugin remove io.github.kaaldev73.dialog-fit`. The plugin only runs
`hyprctl` (read-only queries and a resize/move of the new window); it touches no files.

## Behavior and limits
- Acts once, ~300 ms after a window opens. Never touches a window later, so manual resizing is respected.
- Skips tiled windows and a built-in list of classes that are small on purpose (Omarchy's own dialogs,
  polkit, mixers, calculator, RustDesk). Edit the `skip` list in `DialogFit.js` to change it, along with
  `minWidth`, `minHeight`, `targetWidth`, `targetHeight`.
- Uses Hyprland's Lua-config dispatch (`hl.dsp.window.resize` / `move`), so it needs Hyprland with the
  Lua config (Omarchy 4+ era, tested on Hyprland 0.56.2).
- Heuristic: a legitimately tiny floating window not on the skip list would be enlarged.
- Does not fix bugs inside apps (e.g. Unreal Editor popup rendering on native Wayland).

## Development
`DialogFit.js` holds the logic (`plan()`), kept free of QML so it can be unit-tested with Node.
Validate with `omarchy plugin validate .`

MIT licensed.
