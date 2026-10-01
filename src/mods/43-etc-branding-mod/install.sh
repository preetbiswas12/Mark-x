set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Customization complete. Updating lsb/os-release files"
cat << EOF > /etc/lsb-release
DISTRIB_ID=$TARGET_BUSINESS_NAME
DISTRIB_RELEASE=$TARGET_BUILD_VERSION
DISTRIB_CODENAME=$TARGET_CODENAME
DISTRIB_DESCRIPTION="$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION"
EOF
judge "Update lsb-release"

# ID is the MARKX name, but ID_LIKE advertises ubuntu+debian so that tooling
# which gates on ID_LIKE (add-apt-repository, most vendor .deb installers)
# still resolves dependencies correctly. Set MARKX_ID_UBUNTU_COMPAT=true to
# additionally claim ID=ubuntu, at the cost of generic branding.
if [ "$MARKX_ID_UBUNTU_COMPAT" == "true" ]; then
    OS_ID="ubuntu"
    print_warn "MARKX_ID_UBUNTU_COMPAT=true: /etc/os-release will report ID=ubuntu"
else
    OS_ID="$TARGET_NAME"
fi

cat << EOF > /etc/os-release
PRETTY_NAME="$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION"
NAME="$TARGET_BUSINESS_NAME"
VERSION_ID="$TARGET_BUILD_VERSION"
VERSION="$TARGET_BUILD_VERSION ($TARGET_CODENAME)"
VERSION_CODENAME=$TARGET_CODENAME
ID=$OS_ID
ID_LIKE="ubuntu debian"
HOME_URL="$TARGET_HOME_URL"
SUPPORT_URL="$TARGET_SUPPORT_URL"
BUG_REPORT_URL="$TARGET_BUG_REPORT_URL"
PRIVACY_POLICY_URL="$TARGET_PRIVACY_URL"
UBUNTU_CODENAME=$TARGET_UBUNTU_VERSION
EOF
judge "Update os-release"

print_ok "Patching /etc/legal"
cat << EOF > /etc/legal

# The programs included with the $TARGET_BUSINESS_NAME system are free software;
# the exact distribution terms for each program are described in the
# individual files in /usr/share/doc/*/copyright.

# $TARGET_BUSINESS_NAME comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
# applicable law.
EOF
judge "Patch /etc/legal"