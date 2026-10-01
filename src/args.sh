#!/bin/bash

#=================================================
#           PLEASE READ THIS BEFORE EDITING
#=================================================
# This file is used to set the environment variables for the build process.
# Before building AnduinOS, you should edit this file to customize the build process.
# It is sourced by the build script and should not be executed directly.
# You can edit this file to customize the build process.
# However, you should not change the variable names or the structure of the file.
# After editing this file, you can run the build script `make` to start the build process.

#==========================
# Builder Environment Variables
#==========================
export DEBIAN_FRONTEND=noninteractive
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export HOME=/root

# Set if build in an interactive way.
# Can be: "-y" or ""
export INTERACTIVE="-y"

#==========================
# Language Information
#==========================

# Set the language environment. Can be: en_US, en_GB, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, vi_VN, th_TH, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_BR, pt_PT, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR, ro_RO
export LANG_MODE="en_US"
# Set the language pack code. Can be: zh, en, ja, ko, vi, th, de, fr, es, ru, it, pt, pt, ar, nl, sv, pl, tr, ro
export LANG_PACK_CODE="en"

export LC_ALL=$LANG_MODE.UTF-8
export LC_CTYPE=$LANG_MODE.UTF-8
export LC_TIME=$LANG_MODE.UTF-8
export LC_NAME=$LANG_MODE.UTF-8
export LC_ADDRESS=$LANG_MODE.UTF-8
export LC_TELEPHONE=$LANG_MODE.UTF-8
export LC_MEASUREMENT=$LANG_MODE.UTF-8
export LC_IDENTIFICATION=$LANG_MODE.UTF-8
export LC_NUMERIC=$LANG_MODE.UTF-8
export LC_PAPER=$LANG_MODE.UTF-8
export LC_MONETARY=$LANG_MODE.UTF-8
export LANG=$LANG_MODE.UTF-8
export LANGUAGE=$LANG_MODE:$LANG_PACK_CODE

# These are the language packs to be installed.
# language-pack-zh-hans   language-pack-zh-hans-base language-pack-gnome-zh-hans \
# language-pack-zh-hant   language-pack-zh-hant-base language-pack-gnome-zh-hant \
# language-pack-en        language-pack-en-base      language-pack-gnome-en \
export LANGUAGE_PACKS="language-pack-$LANG_PACK_CODE* language-pack-gnome-$LANG_PACK_CODE*"

# Just logging. Continue with the rest of the script
echo "Language environment has been set to $LANG_MODE"

#==========================
# OS system information
#==========================

# This is the target Ubuntu version code name for the build.
# It should match the Ubuntu version you are building against.
# For example, if you are building against Ubuntu 22.04 LTS, this should be "jammy".
# If you are building against Ubuntu 24.04 LTS, this should be "noble".
# If you are building against Ubuntu 24.10, this should be "oracular".
# If you are building against Ubuntu 25.04, this should be "plucky".
# If you are building against Ubuntu 25.10, this should be "questing".
# Can be: jammy noble oracular plucky questing
export TARGET_UBUNTU_VERSION="questing"

# This is the apt source for the build.
# It can be any Ubuntu mirror that you prefer.
# The default is the Aiursoft mirror.
# You can change it to any other mirror that you prefer.
# See https://docs.anduinos.com/Install/Select-Best-Apt-Source.html
export BUILD_UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu/"

# This is the name of the target OS.
# Must be lowercase without special characters and spaces
export TARGET_NAME="markx"

# This is the full display name of the target OS.
# Business name. No special characters or spaces
export TARGET_BUSINESS_NAME="MARKX"

# Version number. Must be in the format of x.y.z
export TARGET_BUILD_VERSION="1.0.0"

# This is the release codename, shown in /etc/os-release as VERSION_CODENAME.
# Leave as-is to inherit the Ubuntu codename. Set to override.
export TARGET_CODENAME="$TARGET_UBUNTU_VERSION"

# Fork version. Must be in the format of x.y
# By default, it is the branch name of the git repository.
# WARNING: this runs `git rev-parse` in the CWD. If this tree is not itself a
# git repo, it silently inherits whatever parent repo contains it.
# Branch used for the LICENSE blob link in the generated ISO README. Falls back
# to "main" when the build host is not a git checkout (e.g. a synced copy), so
# the link never renders as .../blob//LICENSE.
export TARGET_BUILD_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
export TARGET_BUILD_BRANCH=${TARGET_BUILD_BRANCH:-main}

#==========================
# MARKX branding
#==========================

# Source-of-truth for every GitHub URL below. Change this one line to move the
# project to a different owner or repository name.
export MARKX_GITHUB_OWNER="preetbiswas12"
export MARKX_GITHUB_REPO="Mark-x"
export MARKX_GITHUB_URL="https://github.com/${MARKX_GITHUB_OWNER}/${MARKX_GITHUB_REPO}"

# Canonical home page. Used in /etc/os-release, /etc/issue, and the ISO README.
export TARGET_HOME_URL="https://github.com/${MARKX_GITHUB_OWNER}"

# Issue tracker / discussion links baked into /etc/os-release.
export TARGET_SUPPORT_URL="${MARKX_GITHUB_URL}/discussions"
export TARGET_BUG_REPORT_URL="${MARKX_GITHUB_URL}/issues"

# Privacy policy link baked into /etc/os-release. Point this at your own policy.
export TARGET_PRIVACY_URL="${MARKX_GITHUB_URL}/blob/main/PRIVACY.md"

# Set to "true" to make /etc/os-release report ID=ubuntu instead of ID=markx.
# Some vendor installers (Anthropic, Ollama, others) hard-gate on ID=ubuntu and
# will refuse to run otherwise. Costs you generic branding in `lsb_release` output.
export MARKX_ID_UBUNTU_COMPAT="false"

# Documentation root, linked from the generated ISO README.md.
export TARGET_DOCS_URL="${MARKX_GITHUB_URL}/tree/main/docs"

# Repository root, linked from the ISO README.md for the LICENSE file.
export TARGET_REPO_URL="${MARKX_GITHUB_URL}"

# Base URL for the in-place upgrade script fetched by `markx upgrade`.
# The script appends /<major.minor> and downloads a shell script from there.
# NOTE: this must be a host you control that serves upgrade scripts. GitHub
# raw/release URLs work for scripts but not for arbitrary paths.
export TARGET_UPGRADE_URL_BASE="${MARKX_GITHUB_URL}/releases/download"

# Base URL for ISO/torrent/sha256 downloads used by `do-anduinos-autorepair`.
# The script appends /<base_version>/<full_version>/<name>.iso and friends.
export TARGET_DOWNLOAD_URL_BASE="${MARKX_GITHUB_URL}/releases/download"

# Guard: refuse to build with unresolved branding URLs.
# These values are baked into /etc/os-release, /etc/issue, the ISO README, and
# the autorepair/upgrade scripts. A placeholder that ships silently produces
# broken links on every install, so fail loudly here instead.
MARKX_URL_VARS=(
  TARGET_HOME_URL
  TARGET_SUPPORT_URL
  TARGET_BUG_REPORT_URL
  TARGET_PRIVACY_URL
  TARGET_DOCS_URL
  TARGET_REPO_URL
  TARGET_UPGRADE_URL_BASE
  TARGET_DOWNLOAD_URL_BASE
)
MARKX_BAD_URLS=()
for _var in "${MARKX_URL_VARS[@]}"; do
  _val="${!_var}"
  if [[ -z "$_val" || "$_val" =~ example\.(org|com) || "$_val" =~ markx-os ]]; then
    MARKX_BAD_URLS+=("$_var=$_val")
  fi
done
if [[ ${#MARKX_BAD_URLS[@]} -gt 0 ]]; then
  echo "Error: unresolved branding URL(s) in src/args.sh:"
  for _bad in "${MARKX_BAD_URLS[@]}"; do
    echo "  $_bad"
  done
  echo "Set real values before building. Override MARKX_BRANDING_CHECK=false to skip."
  if [[ "${MARKX_BRANDING_CHECK:-true}" == "true" ]]; then
    exit 1
  fi
fi
unset _var _val MARKX_URL_VARS MARKX_BAD_URLS

#==========================
# MARKX AI — Modular Artificial Reasoning Kernel (eXtended)
#==========================
# The AI provider, bundled into the ISO by src/mods/50-markx-mod/.
# Can be: "none", "flatpak", "pipx"
#   none:     do not ship any AI component
#   flatpak:  install AI desktop apps from flathub
#   pipx:     install AI tooling into isolated pipx venvs (PEP 668 safe)
# Requires STORE_PROVIDER=flatpak if you use the "flatpak" provider.
export MARKX_AI_PROVIDER="none"

# Space-separated flatpak application IDs (used when MARKX_AI_PROVIDER=flatpak).
export MARKX_AI_FLATPAK_APPS=""

# Space-separated pipx package names (used when MARKX_AI_PROVIDER=pipx).
export MARKX_AI_PIPX_PACKAGES=""

#===========================
# Installer customization
#===========================

# Packages will be uninstalled during the installation process
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"

#============================
# Store experience customization
#============================

# How to install the store. Can be "none", "web", "flatpak", "snap"
# none:     no app store
# web:      use a web shortcut to browse the app store
# flatpak:  use gnome software to browse the app store, and install flatpak as plugin
# snap:     use gnome software to browse the app store, and install snap as plugin
export STORE_PROVIDER="flatpak"

# The mirror URL for flathub. Can be: "https://mirror.sjtu.edu.cn/flathub"
export FLATHUB_MIRROR=""
if [[ "$FLATHUB_MIRROR" != "" && "$STORE_PROVIDER" != "flatpak" ]]; then
    echo "Error: FLATHUB_MIRROR is set, but STORE_PROVIDER is not set to flatpak"
    exit 1
fi

# The gpg file for the flathub mirror. Can be: "https://mirror.sjtu.edu.cn/flathub/flathub.gpg"
export FLATHUB_GPG=""
if [[ "$FLATHUB_GPG" != "" && "$FLATHUB_MIRROR" == "" ]]; then
    echo "Error: FLATHUB_GPG is set, but FLATHUB_MIRROR is not set"
    exit 1
fi

#============================
# Browser configuration
#============================

# How to install Firefox. Can be: "none", "deb", "flatpak", "snap", "official_apt"
# none:     no firefox
# deb:      install firefox-esr from the mozillateam Launchpad PPA with apt
# flatpak:  install firefox from flathub (Only available if STORE_PROVIDER is set to "flatpak")
# snap:     install firefox from snap (Only available if STORE_PROVIDER is set to "snap")
# official_apt: install firefox from Mozilla's own APT repo (packages.mozilla.org)
# TODO: Snap firefox seems to be broken. Investigation required.
#
# NOTE: "deb" is currently unusable on this base. The mozillateam PPA publishes
# an empty package index for questing -- Packages.gz is a 20-byte empty gzip
# stream, SHA256 of Packages is d41d8cd98f00b204e9800998ecf8427e (the empty
# string) -- so `apt install firefox-esr` has no installation candidate. The
# same is true for plucky, oracular, noble and jammy. Verified against
# ppa.launchpadcontent.net on 2026-09-30. This is not a mirror problem: the
# aiursoft mirror returns HTTP 200 and serves the same empty index.
# "official_apt" avoids the PPA entirely and uses Mozilla's own signed repo.
export FIREFOX_PROVIDER="official_apt"
if [[ "$FIREFOX_PROVIDER" == "flatpak" && "$STORE_PROVIDER" != "flatpak" ]]; then
    echo "Error: FIREFOX_PROVIDER is set to flatpak, but STORE_PROVIDER is not set to flatpak"
    exit 1
fi
if [[ "$FIREFOX_PROVIDER" == "snap" && "$STORE_PROVIDER" != "snap" ]]; then
    echo "Error: FIREFOX_PROVIDER is set to snap, but STORE_PROVIDER is not set to snap"
    exit 1
fi

# Optional build-time mirror for the Firefox APT source. When set, the host in
# the sources file is rewritten to this. Only meaningful for "deb" (the PPA) or
# "official_apt" (packages.mozilla.org). Leave empty to use upstream directly.
# Sample for the PPA: mirror-ppa.aiursoft.com
export BUILD_FIREFOX_MIRROR=""
if [[ "$BUILD_FIREFOX_MIRROR" != "" && "$FIREFOX_PROVIDER" != "deb" \
      && "$FIREFOX_PROVIDER" != "official_apt" ]]; then
    echo "Error: BUILD_FIREFOX_MIRROR is set, but FIREFOX_PROVIDER is not deb or official_apt"
    exit 1
fi

# The Firefox mirror baked into the live image. When set, it replaces the
# build-time mirror (or the default host) in the shipped sources file.
# This must be set if FIREFOX_PROVIDER is "deb".
# Default for the PPA: ppa.launchpadcontent.net
export LIVE_FIREFOX_MIRROR=""
if [[ "$FIREFOX_PROVIDER" == "deb" && -z "$LIVE_FIREFOX_MIRROR" ]]; then
    echo "Error: FIREFOX_PROVIDER is deb, but didn't set LIVE_FIREFOX_MIRROR"
    exit 1
fi

# Extra locale packages to install alongside Firefox. The ESR locale packages
# are named firefox-esr-locale-*, which only exist in the PPA. Mozilla's own
# repo ships "firefox" without ESR locale splits, so this stays empty for
# "official_apt".
export FIREFOX_LOCALE_PACKAGE=""
if [[ "$FIREFOX_LOCALE_PACKAGE" != "" && "$FIREFOX_PROVIDER" != "deb" ]]; then
    echo "Error: FIREFOX_LOCALE_PACKAGE is set, but FIREFOX_PROVIDER is not set to deb"
    exit 1
fi
#============================
# Third-party asset sources
#============================
# These were previously hardcoded into the mods as git.aiursoft.com URLs.
# That host now returns HTTP 403 for every archive path (verified 2026-09-30),
# which hard-failed the build at mod 24. The aiursoft repos were mirrors of the
# upstream projects, so these point at the originals now:
#   vinceliuice    author of the Fluent themes (README.md credits them)
#   alsa-project   upstream of alsa-ucm-conf
#
# Override any of these to self-host or pin. Keep *_DIR in sync with whatever
# the archive extracts to -- GitHub names it <repo>-<branch>.
export FLUENT_ICON_THEME_URL="https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/heads/master.zip"
export FLUENT_ICON_THEME_DIR="Fluent-icon-theme-master"
export FLUENT_GTK_THEME_URL="https://github.com/vinceliuice/Fluent-gtk-theme/archive/refs/heads/master.zip"
export FLUENT_GTK_THEME_DIR="Fluent-gtk-theme-master"
export ALSA_UCM_CONF_URL="https://github.com/alsa-project/alsa-ucm-conf/archive/refs/heads/master.zip"
export ALSA_UCM_CONF_DIR="alsa-ucm-conf-master"

for _asset in FLUENT_ICON_THEME_URL FLUENT_GTK_THEME_URL ALSA_UCM_CONF_URL; do
    # Deliberately a restricted character class. Keep & and ( ) OUT of it --
    # bash [[ ]] chokes on them in an unquoted regex. These URLs never need
    # query strings, so the tighter match is the safer choice.
    _pat='^https://[A-Za-z0-9._~:/?@%+=,-]+$'
    if [[ ! "${!_asset}" =~ $_pat ]]; then
        echo "Error: $_asset is not a well-formed https URL: ${!_asset}"
        exit 1
    fi
done
unset _asset _pat

#============================
# Input method configuration
#============================

# Packages will be installed during the installation process
# Can be:
# * ibus-rime
# * ibus-libpinyin
# * ibus-chewing
# * ibus-table-cangjie
# * ibus-mozc
# * ibus-hangul
# * ibus-unikey
# * ibus-libthai
export INPUT_METHOD_INSTALL=""

# Boolean indicator for whether to install anduinos-ibus-rime
export CONFIG_IBUS_RIME="false"
if [[ "$CONFIG_IBUS_RIME" == "true" && "$INPUT_METHOD_INSTALL" != *"ibus-rime"* ]]; then
    echo "Error: CONFIG_IBUS_RIME is set to true, but INPUT_METHOD_INSTALL is not set to ibus-rime"
    exit 1
fi

# The default keyboard layout. Can be:
# * [('xkb', 'us')]
# * [('xkb', 'us'), ('ibus', 'rime')]
# * [('xkb', 'us'), ('ibus', 'chewing')]
# * [('xkb', 'us'), ('xkb', 'fr')]
export CONFIG_INPUT_METHOD="[('xkb', 'us')]"

#============================
# Software properties configuration
#============================

# To install software-properties-gtk, set to "true" or "false"
export INSTALL_MODIFIED_SOFTWARE_PROPERTIES_GTK="true"

#============================
# Time zone configuration
#============================

# The timezone for the new OS being built (In chroot environment)
# To view available options, run: `ls /usr/share/zoneinfo/`
export TIMEZONE="America/Los_Angeles"

#============================
# Weather plugin configuration
#============================

# This will affect the default weather location in the weather plugin.
export CONFIG_WEATHER_LOCATION="['{\"name\":\"San Francisco, California, United States\",\"lat\":37.7749295,\"lon\":-122.4194155}']"

#============================
# Live system configuration
#============================

# This is the default apt server in the live system.
# It can be any Ubuntu mirror that you prefer.
export LIVE_UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu/"

#============================
# System apps configuration
#============================
# The default apps to be installed.
# All those apps are optional. You can remove any of them if you don't need them.
export DEFAULT_APPS="
    gnome-chess \
    gnome-clocks \
    gnome-weather \
    gnome-nettool \
    gnome-calendar \
    gnome-text-editor \
    seahorse \
    papers \
    shotwell \
    remmina remmina-plugin-rdp \
    rhythmbox rhythmbox-plugins \
    totem totem-plugins \
    transmission-gtk transmission-common \
    ffmpegthumbnailer \
    libgdk-pixbuf2.0-bin \
    usb-creator-gtk \
    baobab \
    file-roller \
    gnome-sushi \
    qalculate-gtk \
    yelp \
    gnome-shell-extension-prefs \
    gnome-user-docs \
    gnome-disk-utility \
    gnome-logs \
    gnome-system-monitor \
    gnome-sound-recorder \
    gnome-characters \
    gnome-bluetooth \
    gnome-power-manager \
    gnome-snapshot \
    gnome-font-viewer \
    gnome-browser-connector \
    gnome-online-accounts \
    gnome-control-center-faces \
    policykit-desktop-privileges
"

# The default CLI tools to be installed.
# All those tools are optional. You can remove any of them if you don't need them.
export DEFAULT_CLI_TOOLS="
    curl \
    vim \
    nano \
    git \
    build-essential \
    make \
    gcc \
    g++ \
    dpkg-dev \
    net-tools \
    htop \
    httping \
    iputils-ping \
    iputils-tracepath \
    dnsutils \
    smartmontools \
    traceroute \
    whois \
    nmap \
    fastfetch
    "

# The default Flatpak tools to be installed.
# All those tools are optional. You can remove any of them if you don't need them.
export DEFAULT_FLATPAK_TOOLS=""
# export DEFAULT_FLATPAK_TOOLS="
#     chat.revolt.RevoltDesktop \
#     com.discordapp.Discord \
#     com.google.EarthPro \
#     com.jetbrains.Rider \
#     com.obsproject.Studio \
#     com.spotify.Client \
#     com.tencent.WeChat \
#     com.valvesoftware.Steam \
#     io.github.shiftey.Desktop \
#     net.agalwood.Motrix \
#     org.musescore.MuseScore \
#     org.qbittorrent.qBittorrent \
#     org.signal.Signal \
#     org.gnome.Boxes \
#     org.kde.krita \
#     io.missioncenter.MissionCenter \
#     com.getpostman.Postman \
#     org.shotcut.Shotcut \
#     org.blender.Blender \
#     org.videolan.VLC \
#     com.wps.Office \
#     org.chromium.Chromium \
#     com.dosbox_x.DOSBox-X \
#     com.mojang.Minecraft \
#     org.codeblocks.codeblocks
#     "
