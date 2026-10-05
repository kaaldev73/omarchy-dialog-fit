#!/bin/bash
# Installs Omarchy app fixes for Blender and Unreal Editor on Hyprland/Wayland.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
HYPR=~/.config/hypr
APPS=~/.local/share/applications
HOOKS=~/.config/omarchy/hooks/post-update.d
STAMP=$(date +%Y%m%d-%H%M%S)

# 1. Hyprland rules module
cp "$HERE/app-fixes.lua" "$HERE/auto-dialog-size.lua" "$HYPR/"
if ! grep -q 'hypr.app-fixes' "$HYPR/hyprland.lua"; then
  cp "$HYPR/hyprland.lua" "$HYPR/hyprland.lua.app-fixes-backup-$STAMP"
  # Drop the inline rule blocks that now live in app-fixes.lua (everything from the Unreal marker on).
  sed -i '/^-- Unreal Editor detached windows/,$d' "$HYPR/hyprland.lua"
  printf '\n-- Per-app fixes (Blender/Unreal on Wayland): see ~/.config/hypr/app-fixes.lua\nrequire("hypr.app-fixes")\n' >> "$HYPR/hyprland.lua"
fi

# 2. Blender: launch via XWayland (native Wayland opens the file dialog at 320x240)
if [ -f /usr/share/applications/blender.desktop ]; then
  mkdir -p "$APPS"
  sed 's|^Exec=blender |Exec=env WAYLAND_DISPLAY= blender |' /usr/share/applications/blender.desktop > "$APPS/blender.desktop"
fi

# 3. Unreal: X11 video driver, re-applied after Omarchy updates
if [ -n "${UE_ROOT:-}" ]; then mkdir -p ~/.config/omarchy-app-fixes; echo "$UE_ROOT" > ~/.config/omarchy-app-fixes/ue_root; fi
bash "$HERE/ensure-unreal-x11.sh"
mkdir -p "$HOOKS"
install -m 755 "$HERE/ensure-unreal-x11.sh" "$HOOKS/unreal-x11"

hyprctl reload >/dev/null; sleep 1
ERR=$(hyprctl configerrors); echo "hyprctl configerrors: ${ERR:-none}"
echo "Done. Restart Blender and Unreal Editor to pick up the changes."
