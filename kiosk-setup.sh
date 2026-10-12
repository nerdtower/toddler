#!/bin/bash
#
# kiosk-setup.sh - Lock a spare Linux laptop down to toddler.sh
# Copyright (c) 2024 Nerd Tower LLC
# Licensed under the MIT License - see LICENSE file for details
#
# Boots straight into toddler.sh on the text console (no desktop), as a
# separate "toddler" user, with console switching, Ctrl+Alt+Del, SysRq and
# the power/suspend keys turned off.
#
# Usage: sudo ./kiosk-setup.sh install|uninstall
#
# Needs systemd and the kbd tools (dumpkeys, loadkeys).
set -euo pipefail

KID_USER=toddler
BIN=/usr/local/bin
STATE=/etc/toddler-kiosk
GETTY_DROPIN=/etc/systemd/system/getty@tty1.service.d/toddler-kiosk.conf
KEYMAP_UNIT=/etc/systemd/system/toddler-keymap.service
SYSCTL_CONF=/etc/sysctl.d/90-toddler-kiosk.conf
LOGIND_CONF=/etc/systemd/logind.conf.d/toddler-kiosk.conf

die() {
    echo "kiosk-setup: $*" >&2
    exit 1
}

install_kiosk() {
    local adult_user="${SUDO_USER:-}"
    [ -n "$adult_user" ] && [ "$adult_user" != root ] ||
        die "run with sudo from your own account; that account becomes the adult login"
    local tool
    for tool in systemctl agetty dumpkeys loadkeys useradd su; do
        command -v "$tool" >/dev/null || die "missing $tool"
    done

    mkdir -p "$STATE"

    # The game and the login shell that runs it
    install -m 0755 "$(dirname "$0")/toddler.sh" "$BIN/toddler.sh"
    cat > "$BIN/toddler-session" <<EOF
#!/bin/bash
# Login shell for the toddler kiosk user, installed by kiosk-setup.sh

# Bigger console font when one is installed
for font in ter-v32b Lat15-TerminusBold32x16 Uni2-TerminusBold32x16; do
    setfont "\$font" 2>/dev/null && break
done

# The adult exit sequence (z, 9, !) ends toddler.sh and asks for the adult
# password. A wrong password or a closed shell goes straight back to the game.
while true; do
    $BIN/toddler.sh
    su - $adult_user
done
EOF
    chmod 0755 "$BIN/toddler-session"

    # Kid account with no password; it only ever logs in through autologin
    if ! id "$KID_USER" >/dev/null 2>&1; then
        useradd --create-home --shell "$BIN/toddler-session" "$KID_USER"
    else
        usermod --shell "$BIN/toddler-session" "$KID_USER"
    fi

    # Autologin on tty1
    mkdir -p "$(dirname "$GETTY_DROPIN")"
    cat > "$GETTY_DROPIN" <<EOF
[Service]
ExecStart=
ExecStart=-$(command -v agetty) --autologin $KID_USER --noclear %I \$TERM
EOF

    # Boot to the text console instead of the desktop
    [ -f "$STATE/previous-target" ] || systemctl get-default > "$STATE/previous-target"
    systemctl set-default multi-user.target

    # Remove console-switching, reboot, and Scroll Lock (screen freeze) keys from the keymap
    cat > "$BIN/toddler-keymap" <<'EOF'
#!/bin/sh
# Installed by kiosk-setup.sh
dumpkeys -C /dev/tty1 --keys-only |
    sed -E 's/\b((Incr|Decr|Last|Spawn)_)?Console(_[0-9]+)?\b|\b(Boot|Scroll_Lock|KeyboardSignal|Show_Memory|Show_Registers|Show_State)\b/VoidSymbol/g' |
    loadkeys -C /dev/tty1
EOF
    chmod 0755 "$BIN/toddler-keymap"
    cat > "$KEYMAP_UNIT" <<EOF
[Unit]
Description=Disable console switching and reboot keys for the toddler kiosk
After=systemd-vconsole-setup.service
Before=getty@tty1.service

[Service]
Type=oneshot
ExecStart=$BIN/toddler-keymap

[Install]
WantedBy=multi-user.target
EOF

    # Ctrl+Alt+Del and SysRq
    systemctl mask ctrl-alt-del.target
    echo "kernel.sysrq = 0" > "$SYSCTL_CONF"

    # Power, suspend, hibernate and reboot keys (holding power still forces off)
    mkdir -p "$(dirname "$LOGIND_CONF")"
    cat > "$LOGIND_CONF" <<'EOF'
[Login]
HandlePowerKey=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleRebootKey=ignore
EOF

    systemctl daemon-reload
    systemctl enable toddler-keymap.service

    echo "Installed. Reboot to start the kiosk."
    echo "Adult exit: press z, 9, ! quickly, then enter the password for $adult_user."
}

uninstall_kiosk() {
    systemctl disable toddler-keymap.service 2>/dev/null || true
    systemctl unmask ctrl-alt-del.target
    if [ -f "$STATE/previous-target" ]; then
        systemctl set-default "$(cat "$STATE/previous-target")"
    else
        systemctl set-default graphical.target
    fi

    rm -f "$GETTY_DROPIN" "$KEYMAP_UNIT" "$SYSCTL_CONF" "$LOGIND_CONF" \
        "$BIN/toddler-keymap" "$BIN/toddler-session" "$BIN/toddler.sh"
    rmdir "$(dirname "$GETTY_DROPIN")" 2>/dev/null || true
    rm -rf "$STATE"

    systemctl daemon-reload

    echo "Uninstalled. Reboot to get the desktop and normal keys back."
    echo "The $KID_USER account was kept; remove it with: sudo userdel -r $KID_USER"
}

[ "$(id -u)" -eq 0 ] || die "run with sudo"

case "${1:-}" in
    install) install_kiosk ;;
    uninstall) uninstall_kiosk ;;
    *) echo "Usage: sudo $0 install|uninstall" >&2; exit 1 ;;
esac
