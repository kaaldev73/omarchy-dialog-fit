#!/bin/bash
# Make Unreal Editor use X11/XWayland (native Wayland popups render transparent/empty on Hyprland).
# Idempotent. Installed as an Omarchy post-update hook so engine updates can't silently undo it.
CONF="$HOME/.config/omarchy-app-fixes/ue_root"
UE_ROOT="${UE_ROOT:-$( [ -f "$CONF" ] && cat "$CONF" )}"
[ -n "$UE_ROOT" ] || { echo "ensure-unreal-x11: UE_ROOT not set, skipping Unreal"; exit 0; }
INI="$UE_ROOT/Engine/Config/Linux/LinuxEngine.ini"
[ -f "$INI" ] || { echo "ensure-unreal-x11: $INI not found, skipping"; exit 0; }
grep -q '^VideoDriver=x11' "$INI" && exit 0
[ -e "$INI.pre-x11-backup" ] || cp "$INI" "$INI.pre-x11-backup"
chmod u+w "$INI"
printf '\n[Linux.SDL]\nVideoDriver=x11\n' >> "$INI"
chmod a-w "$INI"
echo "ensure-unreal-x11: set VideoDriver=x11 in $INI"
