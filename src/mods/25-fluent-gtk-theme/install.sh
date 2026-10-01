set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing Fluent theme"
mkdir -p ./themes/
wget "$FLUENT_GTK_THEME_URL" -O ./themes/fluent-gtk-theme.zip
unzip -q -O UTF-8 ./themes/fluent-gtk-theme.zip -d ./themes/
# See 24-fluent-icon-theme: normalise the extract dir name for the cd below.
if [ ! -d "./themes/fluent-gtk-theme" ]; then
    if [ -d "./themes/$FLUENT_GTK_THEME_DIR" ]; then
        mv "./themes/$FLUENT_GTK_THEME_DIR" ./themes/fluent-gtk-theme/
    else
        print_error "Expected ./themes/fluent-gtk-theme or ./themes/$FLUENT_GTK_THEME_DIR after unzip"
        ls -la ./themes/ || true
        exit 1
    fi
fi
judge "Download Fluent theme"

(
    cd ./themes/fluent-gtk-theme/ && \
    ./install.sh --tweaks noborder round --theme all 
)
judge "Install Fluent theme"