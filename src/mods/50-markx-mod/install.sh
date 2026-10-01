set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# MARKX — Modular Artificial Reasoning Kernel (eXtended)
# Bundles the AI layer into the image. Configured entirely from src/args.sh via:
#   MARKX_AI_PROVIDER       none | flatpak | pipx
#   MARKX_AI_FLATPAK_APPS   space-separated flatpak app IDs
#   MARKX_AI_PIPX_PACKAGES  space-separated pipx package names
#
# Execution order note: this mod is numbered 50 so that it sorts after
#   14-gnome-apps-mod      (python3, pipx, gnupg, apt-transport-https)
#   17-appstore-app        (flatpak + flathub remote)
#   41-target-apt-mirror-mod (final apt sources)
# and before
#   79-useless-package-remover  (aborts the build on unexpected packages)
#   80-initramfs-update         (rebuilds the live initramfs)
#   84-apt-cache-cleaner

print_ok "MARKX AI: configuring (provider=$MARKX_AI_PROVIDER)"

# Guard: flatpak provider is meaningless without a flatpak store.
if [[ "$MARKX_AI_PROVIDER" == "flatpak" && "$STORE_PROVIDER" != "flatpak" ]]; then
    print_error "MARKX_AI_PROVIDER=flatpak requires STORE_PROVIDER=flatpak in args.sh"
    exit 1
fi

# -----------------------------------------------------------------------------
# 1. Provider-specific package installation
# -----------------------------------------------------------------------------
case "$MARKX_AI_PROVIDER" in
    none)
        print_info "MARKX_AI_PROVIDER=none — skipping AI package installation."
        ;;

    flatpak)
        print_ok "Installing MARKX AI desktop applications from flathub..."
        install_opt flatpak

        if ! flatpak remotes --columns=name | grep -qx "flathub"; then
            print_ok "Adding official flathub repository..."
            flatpak remote-add --if-not-exists flathub \
                https://dl.flathub.org/repo/flathub.flatpakrepo
            judge "Add official flathub repository"
        fi

        for app in $MARKX_AI_FLATPAK_APPS; do
            print_ok "Installing $app..."
            # Non-fatal: a single unavailable app should not kill the build.
            if flatpak install -y --noninteractive flathub "$app"; then
                judge "Install $app"
            else
                print_warn "Could not install $app (unavailable for this arch) — continuing"
            fi
        done
        judge "Install MARKX AI flatpak apps"
        ;;

    pipx)
        # pipx creates isolated venvs, which is the correct way around PEP 668's
        # externally-managed-environment. A bare `pip install` will fail.
        print_ok "Installing MARKX AI tooling via pipx..."
        install_opt pipx

        for pkg in $MARKX_AI_PIPX_PACKAGES; do
            print_ok "Installing $pkg..."
            if pipx install "$pkg"; then
                judge "Install $pkg"
            else
                print_warn "Could not install $pkg — continuing"
            fi
        done
        judge "Install MARKX AI pipx packages"
        ;;

    *)
        print_error "Unknown MARKX_AI_PROVIDER: $MARKX_AI_PROVIDER"
        print_error "Valid values: none, flatpak, pipx"
        exit 1
        ;;
esac

# -----------------------------------------------------------------------------
# 2. Local model policy
# -----------------------------------------------------------------------------
# No model weights are baked into the ISO. Multi-GB payloads would make the
# zstd -Xcompression-level 19 squashfs step in build.sh prohibitively slow and
# would leave users with a stale model they cannot replace. The CLI, config
# file, and launcher ship; the backend is installed at runtime via `markx setup`.

# -----------------------------------------------------------------------------
# 3. Config directory
# -----------------------------------------------------------------------------
print_ok "Creating MARKX configuration directory..."
mkdir -p /etc/markx
chmod 755 /etc/markx
judge "Create /etc/markx"

print_ok "Writing default MARKX configuration..."
cat << EOF > /etc/markx/markx.conf
# MARKX — Modular Artificial Reasoning Kernel (eXtended)
# Edit this file, or run \`markx setup\`, to point MARKX at a provider.
MARKX_AI_PROVIDER=$MARKX_AI_PROVIDER
MARKX_HOME_URL=$TARGET_HOME_URL
MARKX_DOCS_URL=$TARGET_DOCS_URL
EOF
chmod 644 /etc/markx/markx.conf
judge "Write /etc/markx/markx.conf"

# -----------------------------------------------------------------------------
# 4. The `markx` command
# -----------------------------------------------------------------------------
print_ok "Adding new command to this OS: markx..."
cat << "MKEOF" > /usr/local/bin/markx
#!/bin/bash
# MARKX — Modular Artificial Reasoning Kernel (eXtended)
set -o pipefail

CONF="/etc/markx/markx.conf"
[[ -f "$CONF" ]] && . "$CONF"

PURPLE="\033[35m"
CYAN="\033[36m"
RED="\033[31m"
GREEN="\033[32m"
NC="\033[0m"

die() { echo -e "${RED}[markx]${NC} $*" >&2; exit 1; }
info() { echo -e "${PURPLE}[markx]${NC} $*"; }

banner() {
    echo -e "${CYAN}"
    echo "  __  __  __  __  ___ _____ ____ "
    echo " |  \\/  |/ _ \\|  \\/  |_   _|  _ \\"
    echo " | |\\/| | | | | |\\/| | | | | |_) |"
    echo " | |  | | |_| | |  | | | | |  _ < "
    echo " |_|  |_|\\___/|_|  |_| |_| |_| \\_\\"
    echo -e "${NC}"
    echo "  Modular Artificial Reasoning Kernel - eXtended"
    echo "  ${MARKX_AI_PROVIDER:-none} provider"
    echo
}

cmd_status() {
    banner
    info "Configuration"
    echo "  config file : $CONF"
    echo "  provider    : ${MARKX_AI_PROVIDER:-none}"
    echo "  docs        : ${MARKX_DOCS_URL:-unset}"
    echo
    info "Runtime detection"
    for bin in ollama llama-cli llm gpt4all llava mistral; do
        if command -v "$bin" >/dev/null 2>&1; then
            echo "  found       : $bin -> $(command -v "$bin")"
        fi
    done
    if flatpak remotes 2>/dev/null | grep -q flathub; then
        echo "  flathub     : present"
    fi
    echo
    info "No local model is bundled. Add one with: markx setup"
}

cmd_run() {
    if command -v ollama >/dev/null 2>&1; then
        exec ollama run "${MARKX_MODEL:-llama3.2}" "$@"
    fi
    die "no local inference backend found. Run 'markx setup' first."
}

cmd_setup() {
    info "MARKX setup"
    echo "  This installs a local inference backend. It requires network access."
    echo
    echo "  Recommended: Ollama"
    echo "    curl -fsSL https://ollama.com/install.sh | sh"
    echo "    ollama pull llama3.2"
    echo
    echo "  Then re-run: markx run \"hello\""
    echo
    echo "  Docs: ${MARKX_DOCS_URL:-unset}"
}

case "${1:-}" in
    status)  cmd_status ;;
    run)     shift; cmd_run "$@" ;;
    setup)   cmd_setup ;;
    -h|--help|help|"")
        banner
        echo "Usage: markx <command>"
        echo
        echo "  status    Show provider, config, and detected backends"
        echo "  run       Start a local inference session"
        echo "  setup     Print backend installation instructions"
        echo "  help      Show this message"
        ;;
    *)
        banner
        echo "Unknown command: $1"
        echo "Run 'markx help' for usage."
        exit 1
        ;;
esac
MKEOF
chmod +x /usr/local/bin/markx
judge "Add new command markx"

# -----------------------------------------------------------------------------
# 5. Desktop launcher
# -----------------------------------------------------------------------------
print_ok "Adding desktop entry for MARKX..."
cat << DEOF > /usr/share/applications/markx.desktop
[Desktop Entry]
Name=MARKX
GenericName=Modular Artificial Reasoning Kernel
Comment=Ask the deep — your local AI reasoning assistant
Exec=markx run
Icon=applications-science
Terminal=true
Type=Application
Categories=Development;Utility;
StartupNotify=true
DEOF
chmod 644 /usr/share/applications/markx.desktop
judge "Add desktop entry markx.desktop"

# -----------------------------------------------------------------------------
# 6. Verify
# -----------------------------------------------------------------------------
print_ok "Verifying MARKX installation..."
command -v markx >/dev/null 2>&1 || {
    print_error "markx not on PATH after install (PATH=$PATH)"
    print_error "expected it at /usr/local/bin/markx: $(ls -l /usr/local/bin/markx 2>&1)"
    exit 1
}
markx --help >/dev/null 2>&1 || { print_error "markx --help failed"; exit 1; }
judge "Verify markx CLI"

print_ok "MARKX AI layer installed successfully."
