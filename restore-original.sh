#!/bin/bash
# Reverts apply-fix.sh.
set -euo pipefail
HYPR=~/.config/hypr
UE_ROOT="${UE_ROOT:-$(cat ~/.config/omarchy-app-fixes/ue_root 2>/dev/null)}"
INI="$UE_ROOT/Engine/Config/Linux/LinuxEngine.ini"

BK=$(ls -1t "$HYPR"/hyprland.lua.app-fixes-backup-* 2>/dev/null | head -1 || true)
[ -n "$BK" ] && cp "$BK" "$HYPR/hyprland.lua" && echo "restored $BK"
rm -f "$HYPR/app-fixes.lua" "$HYPR/auto-dialog-size.lua" ~/.local/share/applications/blender.desktop ~/.config/omarchy/hooks/post-update.d/unreal-x11 ; rm -rf ~/.config/omarchy-app-fixes
if [ -n "$UE_ROOT" ] && [ -f "$INI.pre-x11-backup" ]; then
  chmod u+w "$INI"; cp "$INI.pre-x11-backup" "$INI"; chmod a-w "$INI"; echo "restored $INI"
fi
hyprctl reload >/dev/null; sleep 1; echo "hyprctl configerrors: $(hyprctl configerrors || true)"
