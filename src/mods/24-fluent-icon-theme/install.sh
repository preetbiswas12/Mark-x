set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Downloading Fluent icon theme"
mkdir -p ./themes/
wget "$FLUENT_ICON_THEME_URL" -O ./themes/fluent-icon-theme.zip
unzip -q -O UTF-8 ./themes/fluent-icon-theme.zip -d ./themes/
# Archives normally extract to <repo>-<branch>; normalise to the name the
# steps below cd into so a different source URL does not silently break them.
if [ ! -d "./themes/fluent-icon-theme" ]; then
    if [ -d "./themes/$FLUENT_ICON_THEME_DIR" ]; then
        mv "./themes/$FLUENT_ICON_THEME_DIR" ./themes/fluent-icon-theme/
    else
        print_error "Expected ./themes/fluent-icon-theme or ./themes/$FLUENT_ICON_THEME_DIR after unzip"
        ls -la ./themes/ || true
        exit 1
    fi
fi
judge "Download Fluent icon theme"

print_ok "Installing Fluent icon theme"
(
    print_ok "Installing Fluent icon theme" && \
    cd ./themes/fluent-icon-theme/ && \
    ./install.sh --all
)
judge "Install Fluent icon theme"

#==============================================

print_ok "Installing Fluent cursor theme"
(
    print_ok "Installing Fluent cursor theme" && \
    cd ./themes/fluent-icon-theme/cursors/ && \
    ./install.sh
)
judge "Install Fluent cursor theme"