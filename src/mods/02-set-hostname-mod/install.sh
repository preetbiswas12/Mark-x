set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Setting up hostname..."
echo "$TARGET_NAME" > /etc/hostname
# Deliberately NOT running `hostname` here. This runs inside a chroot, which
# shares the BUILD HOST's UTS namespace, so it would rename the build machine
# itself and make every subsequent sudo call warn "unable to resolve host".
# The installed system reads /etc/hostname at boot, which is all that matters.
judge "Set up hostname to $TARGET_NAME"

print_ok "Configuring locales and resolvconf..."
apt update
apt install $INTERACTIVE \
    locales \
    resolvconf \
    apt-utils \
    --no-install-recommends
judge "Install locales and resolvconf"

print_ok "Configuring locales..."
echo "$LANG UTF-8" > /etc/locale.gen
locale-gen
update-locale LANG=$LANG LC_ALL=$LANG
judge "Configure locales"
