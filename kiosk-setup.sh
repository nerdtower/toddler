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
# install-boot-option does the same, but only when "Toddler" is picked in the
# GRUB menu; a normal boot is the untouched desktop.
#
# Usage: sudo ./kiosk-setup.sh [install|install-boot-option|uninstall]
# With no argument it asks which one.
#
# Needs systemd and the kbd tools (dumpkeys, loadkeys). install-boot-option
# also needs GRUB with update-grub (Debian, Ubuntu, Mint).
set -euo pipefail

KID_USER=toddler
BIN=/usr/local/bin
STATE=/etc/toddler-kiosk
GETTY_DROPIN=/etc/systemd/system/getty@tty1.service.d/toddler-kiosk.conf
KEYMAP_UNIT=/etc/systemd/system/toddler-keymap.service
SYSCTL_CONF=/etc/sysctl.d/90-toddler-kiosk.conf
LOGIND_CONF=/etc/systemd/logind.conf.d/toddler-kiosk.conf
LOCKDOWN_UNIT=/etc/systemd/system/toddler-lockdown.service
CONSOLE_UNIT=/etc/systemd/system/toddler-console.service
GETTY_SKIP=/etc/systemd/system/getty@tty1.service.d/toddler-boot-option.conf
GRUB_SCRIPT=/etc/grub.d/42_toddler
GRUB_DEFAULTS=/etc/default/grub.d/99-toddler.cfg
# Kernel argument the Toddler boot entry adds; everything boot-option installs
# checks for it. Dotted, so the kernel keeps it away from init's arguments.
BOOT_ARG=toddler.kiosk

die() {
    echo "kiosk-setup: $*" >&2
    exit 1
}

logind_conf() {
    cat <<'EOF'
[Login]
HandlePowerKey=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleRebootKey=ignore
EOF
}

# The game, the toddler account and the keymap script, shared by both installs
install_game() {
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

    usermod --lock "$KID_USER"

    # Remove console-switching, reboot (Ctrl+Alt+Del), and Scroll Lock (screen freeze) keys from the keymap
    cat > "$BIN/toddler-keymap" <<'EOF'
#!/bin/sh
# Installed by kiosk-setup.sh
dumpkeys -C /dev/tty1 --keys-only |
    sed -E 's/\b((Incr|Decr|Last|Spawn)_)?Console(_[0-9]+)?\b|\b(Boot|Scroll_Lock|KeyboardSignal|Show_Memory|Show_Registers|Show_State)\b/VoidSymbol/g' |
    loadkeys -C /dev/tty1
EOF
    chmod 0755 "$BIN/toddler-keymap"
}

install_kiosk() {
    [ ! -e "$CONSOLE_UNIT" ] || die "the boot menu option is installed; run uninstall first"
    install_game

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
    logind_conf > "$LOGIND_CONF"

    systemctl daemon-reload
    systemctl enable toddler-keymap.service

    echo "Installed. Reboot to start the kiosk."
    echo "Adult exit: press z, 9, ! quickly, then enter the password for $SUDO_USER."
}

install_boot_option() {
    [ ! -e "$GETTY_DROPIN" ] || die "the always-on kiosk is installed; run uninstall first"
    command -v update-grub >/dev/null || die "missing update-grub (needs GRUB on Debian, Ubuntu or Mint)"
    [ "$(findmnt -no FSTYPE /)" != zfs ] || die "a ZFS root isn't supported; use install instead"
    install_game

    # Lockdown for the Toddler boot only, all of it gone on the next reboot:
    # keymap, SysRq, and a runtime logind drop-in written before logind starts.
    # Ctrl+Alt+Del is covered by the keymap (it removes the Boot key).
    logind_conf > "$STATE/logind.conf"
    cat > "$LOCKDOWN_UNIT" <<EOF
[Unit]
Description=Toddler kiosk lockdown (Toddler boot entry only)
ConditionKernelCommandLine=$BOOT_ARG
After=systemd-vconsole-setup.service keyboard-setup.service console-setup.service
Before=systemd-logind.service toddler-console.service

[Service]
Type=oneshot
ExecStart=-$(command -v sysctl) -q kernel.sysrq=0
ExecStart=-/bin/mkdir -p /run/systemd/logind.conf.d
ExecStart=-/bin/cp $STATE/logind.conf /run/systemd/logind.conf.d/toddler-kiosk.conf
ExecStart=-$BIN/toddler-keymap

[Install]
WantedBy=multi-user.target
EOF

    # Autologin on tty1, in place of the normal getty, on the Toddler boot only
    cat > "$CONSOLE_UNIT" <<EOF
[Unit]
Description=Toddler autologin on tty1 (Toddler boot entry only)
ConditionKernelCommandLine=$BOOT_ARG
After=systemd-user-sessions.service plymouth-quit-wait.service toddler-lockdown.service

[Service]
ExecStart=-$(command -v agetty) --autologin $KID_USER --noclear tty1 linux
Type=idle
Restart=always
RestartSec=0
UtmpIdentifier=tty1
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
KillMode=process
IgnoreSIGPIPE=no
SendSIGHUP=yes

[Install]
WantedBy=multi-user.target
EOF
    mkdir -p "$(dirname "$GETTY_SKIP")"
    cat > "$GETTY_SKIP" <<EOF
[Unit]
ConditionKernelCommandLine=!$BOOT_ARG
EOF

    # The GRUB entry. update-grub reruns this on every kernel update, so it
    # always points at the newest kernel.
    cat > "$GRUB_SCRIPT" <<'EOF'
#!/bin/sh
# Installed by kiosk-setup.sh: a "Toddler" boot menu entry that starts
# toddler.sh on the text console instead of the desktop. Never fails, so a
# problem here can't break update-grub for the normal entries.
. "$pkgdatadir/grub-mkconfig_lib"

kernel=
initrd=
for link in /boot/vmlinuz /vmlinuz; do
    if [ -e "$link" ]; then kernel=$(readlink -f "$link"); break; fi
done
for link in /boot/initrd.img /initrd.img; do
    if [ -e "$link" ]; then initrd=$(readlink -f "$link"); break; fi
done
if [ ! -e "$kernel" ]; then
    echo "Toddler: no kernel at /boot/vmlinuz, skipping the boot menu entry" >&2
    exit 0
fi

if [ -n "$GRUB_DEVICE_UUID" ] && [ "$GRUB_DISABLE_LINUX_UUID" != true ]; then
    root="UUID=$GRUB_DEVICE_UUID"
else
    root=$GRUB_DEVICE
fi

# As in 10_linux: Ubuntu and Mint btrfs installs put / on a subvolume
cmdline=$GRUB_CMDLINE_LINUX
if [ "$GRUB_FS" = btrfs ]; then
    subvol=$(make_system_path_relative_to_its_root /)
    subvol=${subvol#/}
    [ -z "$subvol" ] || cmdline="rootflags=subvol=$subvol $cmdline"
fi
# Keep hardware workarounds like nomodeset, but no splash screen
cmdline="$cmdline $(echo " $GRUB_CMDLINE_LINUX_DEFAULT " | sed -E 's/ splash / /g')"

echo "Adding boot menu entry for Toddler" >&2
echo "menuentry 'Toddler' --class os {"
prepare_grub_to_access_device "$(${grub_probe} --target=device "$kernel")" | sed 's/^/\t/'
printf '\tlinux %s root=%s ro %s systemd.unit=multi-user.target @BOOT_ARG@\n' \
    "$(make_system_path_relative_to_its_root "$kernel")" "$root" "$cmdline"
if [ -n "$initrd" ]; then
    printf '\tinitrd %s\n' "$(make_system_path_relative_to_its_root "$initrd")"
fi
echo "}"
EOF
    sed -i "s/@BOOT_ARG@/$BOOT_ARG/" "$GRUB_SCRIPT"
    chmod 0755 "$GRUB_SCRIPT"

    # Show the menu at boot; most single-OS installs hide it
    mkdir -p "$(dirname "$GRUB_DEFAULTS")"
    cat > "$GRUB_DEFAULTS" <<'EOF'
# Installed by kiosk-setup.sh
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=5
EOF

    systemctl daemon-reload
    systemctl enable toddler-lockdown.service toddler-console.service
    update-grub
    grep -q "menuentry 'Toddler'" /boot/grub/grub.cfg ||
        die "update-grub didn't add the Toddler entry; see its output above"

    echo "Installed. Reboot and pick Toddler in the boot menu; the first entry is still the desktop."
    echo "Adult exit: press z, 9, ! quickly, then enter the password for $SUDO_USER."
    echo "To update: git pull, then run this again."
}

uninstall_kiosk() {
    systemctl disable toddler-keymap.service toddler-lockdown.service \
        toddler-console.service 2>/dev/null || true
    systemctl unmask ctrl-alt-del.target
    if [ -f "$STATE/previous-target" ]; then
        systemctl set-default "$(cat "$STATE/previous-target")"
    fi

    local had_grub_entry=
    [ ! -e "$GRUB_SCRIPT" ] || had_grub_entry=1

    rm -f "$GETTY_DROPIN" "$KEYMAP_UNIT" "$SYSCTL_CONF" "$LOGIND_CONF" \
        "$LOCKDOWN_UNIT" "$CONSOLE_UNIT" "$GETTY_SKIP" "$GRUB_SCRIPT" "$GRUB_DEFAULTS" \
        "$BIN/toddler-keymap" "$BIN/toddler-session" "$BIN/toddler.sh"
    rmdir "$(dirname "$GETTY_DROPIN")" 2>/dev/null || true
    rm -rf "$STATE"

    systemctl daemon-reload
    [ -z "$had_grub_entry" ] || update-grub

    echo "Uninstalled. Reboot to get the desktop and normal keys back."
    echo "The $KID_USER account was kept; remove it with: sudo userdel -r $KID_USER"
}

[ "$(id -u)" -eq 0 ] || die "run with sudo"

choose_action() {
    local boot_label="Add Toddler to the boot menu (the desktop stays the default)"
    local kiosk_label="Always boot into Toddler (no desktop)"
    local boot_action=install-boot-option kiosk_action=install
    if [ -e "$CONSOLE_UNIT" ]; then
        echo "Installed now: the Toddler boot menu option" >&2
        boot_label="Update the Toddler boot menu option"
        kiosk_label="Switch to always booting into Toddler (no desktop)"
        kiosk_action=switch-to-kiosk
    elif [ -e "$GETTY_DROPIN" ]; then
        echo "Installed now: always boot into Toddler" >&2
        kiosk_label="Update the always-on Toddler kiosk"
        boot_label="Switch to a Toddler boot menu option (the desktop comes back)"
        boot_action=switch-to-boot-option
    fi
    echo "1) $boot_label" >&2
    echo "2) $kiosk_label" >&2
    echo "3) Uninstall" >&2
    echo "4) Quit" >&2
    local choice
    read -rp "Choose 1-4: " choice
    case "$choice" in
        1) echo "$boot_action" ;;
        2) echo "$kiosk_action" ;;
        3) echo uninstall ;;
        4) echo quit ;;
        *) echo "Nothing chosen" >&2; echo quit ;;
    esac
}

action=${1:-}
[ -n "$action" ] || action=$(choose_action)

case "$action" in
    install) install_kiosk ;;
    install-boot-option) install_boot_option ;;
    uninstall) uninstall_kiosk ;;
    switch-to-kiosk) uninstall_kiosk; install_kiosk ;;
    switch-to-boot-option) uninstall_kiosk; install_boot_option ;;
    quit) ;;
    *) echo "Usage: sudo $0 [install|install-boot-option|uninstall]" >&2; exit 1 ;;
esac
