set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Adding new command to this OS: do-anduinos-autorepair..."

# This script is copied into the image, so it cannot read args.sh at runtime.
# Template the distribution name and download base at build time instead.
sed -e "s|__TARGET_BUSINESS_NAME__|$TARGET_BUSINESS_NAME|g" \
    -e "s|__TARGET_DOWNLOAD_URL_BASE__|$TARGET_DOWNLOAD_URL_BASE|g" \
    ./do-anduinos-autorepair.sh > /usr/local/bin/do-anduinos-autorepair
chmod +x /usr/local/bin/do-anduinos-autorepair
judge "Add new command do-anduinos-autorepair"

# Fail the build rather than shipping a repair tool that points at another project.
if grep -qE 'anduinos\.com|AnduinOS-|\bAnduinOS\b' /usr/local/bin/do-anduinos-autorepair; then
    print_error "do-anduinos-autorepair still references upstream AnduinOS endpoints"
    print_error "Fix the sed template in this mod before shipping."
    exit 1
fi
judge "Verify autorepair has no upstream references"
