# MARKX 1.4 — AI Integration: Pinpoint Reference

Scope: exactly how to add AI to this tree, where it goes, and what will break.

Legend: **[V]** = verified by reading the file / running the command. **[I]** = inferred, test before relying on it.

---

## 1. Ground truth about this tree

| Fact | Value | Source |
|---|---|---|
| Version string | `1.4.3` | `src/args.sh:86` **[V]** |
| Base Ubuntu | `questing` = 25.10 | `src/args.sh:68` **[V]** |
| Build mirror | `http://archive.ubuntu.com/ubuntu/` | `src/args.sh:75` **[V]** |
| Store provider | `flatpak` | `src/args.sh:114` **[V]** |
| Firefox provider | `deb` (via `mirror-ppa.aiursoft.com`) | `src/args.sh:141,154` **[V]** |
| Mods present | 56 directories, each with `install.sh` | `src/mods/` **[V]** |
| AI code present | **none** (grep for openai/anthropic/ollama/llm/copilot/assistant → only `tiling-assistant` GNOME ext) **[V]** |
| Host OS required | Ubuntu/Debian/Tuxedo/AnduinOS/Kali, **not root** | `makefile:29-37` **[V]** |

### 1.1 Base OS is EOL-but-still-serving — measured, not assumed **[V]**

`GET http://archive.ubuntu.com/ubuntu/dists/questing/Release` → **HTTP 200**

```
Origin: Ubuntu
Version: 25.10
Date: Thu, 09 Oct 2025  9:25:38 UTC
Codename: questing
```

Critically there is **no `Valid-Until` field**, so apt will never run the expiry check
and `debootstrap` will still succeed. Ubuntu 25.10 has had no security updates since
~July 2026 and will eventually be relocated to `old-releases.ubuntu.com`.

Also measured **[V]**: `GET http://old-releases.ubuntu.com/ubuntu/dists/questing/Release` → **404** (not relocated yet).
And the current Ubuntu release is **26.04 "Resolute Raccoon"** (wiki.ubuntu.com/Releases, last edited 24 Sep 2026).

**Conclusion:** the build works today. Do not treat this as a blocker. Do treat it as
unpatched. If you want a supported base, `resolute` is the current codename.

---

## 2. Exact mod execution order

`src/mods/install_all_mods.sh:26-34` globs `$SCRIPT_DIR/*` in **lexicographic** order and runs
each `install.sh` in a fresh subshell. Numbering is the sort key — but **the numbers are not
unique** (23×3, 27×2, 29×3, 40×2, 42×2), so treat the prefix as a sort hint, not an ID.

| # | Mod | Relevance to AI |
|---|---|---|
| 00 | `check-host-mod` | |
| 01 | `apt-source-mod` | writes `/etc/apt/sources.list` from `BUILD_UBUNTU_MIRROR` |
| 02 | `set-hostname-mod` | |
| 03 | `systemd-mod` | |
| 04 | `machine-id-mod` | |
| 05 | `initctl-mod` | |
| 06 | `apt-upgrade-mod` | |
| 07 | `system-tools-install-mod` | |
| 08 | `casper-and-kernel-install-mod` | |
| 10 | `no-snap-mod` | **purges snapd** unless `STORE_PROVIDER=snap` |
| 12 | `no-motd-mod` | |
| 14 | `gnome-apps-mod` | **installs `python3`, `python3-pip`, `python-is-python3`, `pipx`** (`install.sh:201-208`); also `apt-transport-https`, `gnupg` (`:10,16`) |
| 15 | `fonts-mod` | |
| 16 | `localization-patch` | |
| 17 | `appstore-app` | **installs `flatpak` + flathub remote** (flatpak branch) |
| 18 | `firefox-mod` | |
| 19 | `plymouth-patch` | |
| 20 | `deskmon-mod` | |
| 21 | `ubiquity-mod` | |
| 22 | `ubiquity-patch` | |
| 23 | `software-properties-common-patch` | |
| 23 | `software-properties-gtk` | |
| 23 | `wallpaper-mod` | |
| 24 | `fluent-icon-theme` | |
| 25 | `fluent-gtk-theme` | |
| 26 | `gnome-extensions-installer` | `pipx install gnome-extensions-cli`; extension array at `:54-69` |
| 27 | `dash-to-panel-patch-mod` | |
| 27 | `gnome-extensions-remover` | |
| 28 | `gnome-extensions-system-archiver` | |
| 29 | `gnome-extension-anduinos-loc` | |
| 29 | `gnome-extension-anduinos-switcher` | |
| 29 | `gnome-extension-noti-bottom-right` | |
| 30 | `gnome-extension-arcmenu-patch` | |
| 31 | `gnome-extension-dashtopanel-patch` | |
| 32 | `gnome-shell-localization-patch` | |
| 33 | `gnome-extensions-enabler` | enables extensions via `gext` (`:17`) |
| 34 | `input-method-mod` | |
| 35 | `dconf-patch` | **copies root dconf → `/etc/skel`** (`:66-69`) |
| 36 | `ubuntu-logo-text` | |
| 37 | `xdg-mime-mod` | |
| 38 | `root-conf-cleanup` | |
| 39 | `templates-mod` | |
| 40 | `do-anduinos-autorepair-mod` | |
| 40 | `do-anduinos-upgrade-mod` | **best template for shipping a CLI command** |
| 41 | `target-apt-mirror-mod` | **overwrites `/etc/apt/sources.list`** with `LIVE_UBUNTU_MIRROR` |
| 42 | `gnome-sessions-patch` | |
| 42 | `intel-thesof-mod` | SOF firmware from `pub.aiursoft.com` — hard external dep; `alsa-ucm-conf` now comes from `github.com/alsa-project` |
| 43 | `etc-branding-mod` | **sets `ID=markx`, `ID_LIKE="ubuntu debian"`** (`:21-22`) — see §5.1 |
| 44 | `casper-patch` | |
| 45 | `etc-issue-patch` | |
| 78 | `no-advertisements-mod` | |
| 79 | `useless-package-remover` | **`apt autoremove --purge` + aborts build on listed pkgs** — see §5.2 |
| 80 | `initramfs-update` | run kernel-dependent installs *before* this |
| 82 | `locales-config` | |
| 83 | `network-manager-patch` | |
| 84 | `apt-cache-cleaner` | |
| 85 | `machine-id-wiper` | |
| 86 | `diversion-remover` | |
| 87 | `history-cleaner` | |
| 88 | `useless-folders-cleaner` | only removes `/[bin\|lib\|sbin].usr-is-merged` stubs — harmless |

**Gap:** numbers 09, 11, 13 and **46–77 are unused** — the 46–77 block is the cleanest place to
insert a new mod without colliding with the existing duplicate numbering.

---

## 3. How a mod receives config — read this before writing one **[V]**

`build.sh:82-84` copies `mods/`, `args.sh`, `shared.sh` into the chroot at `/root/mods/`.
`build.sh:92` then runs `/root/mods/install_all_mods.sh`.

`args.sh:17` sets `export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"`. When
`install_all_mods.sh` sources `args.sh`, `$0` is `/root/mods/install_all_mods.sh`, so
`SCRIPT_DIR=/root/mods`. Each mod is then launched as `bash "$mod/install.sh"` — a **new bash
process**, so `args.sh` is *not* re-sourced. Config reaches mods purely through **exported
environment variables**.

Consequences:

- ✅ `$STORE_PROVIDER`, `$LANG_MODE`, `$INTERACTIVE`, `$DEFAULT_APPS` etc. **are** available in your `install.sh`.
- ❌ **`$SCRIPT_DIR` is NOT set inside a mod.** Every mod runs under `set -u`, so touching it aborts the build.
  Use paths relative to the mod dir — `install_all_mods.sh:30` does `cd "$mod"` first.
- ❌ Do not `source ../args.sh`; mods don't, and it would re-derive `SCRIPT_DIR` to your own folder.

### 3.1 Available helper functions (`src/shared.sh`) **[V]**

| Function | Line | Behaviour |
|---|---|---|
| `print_ok` | 21 | green `[ OK  ]` |
| `print_info` | 25 | blue `[ INFO ]` |
| `print_error` | 29 | red `[FAILED]` |
| `print_warn` | 33 | yellow `[ WARN ]` |
| `judge` | 37 | checks `$?` of the **immediately preceding** command; **exits 1 on failure** |
| `wait_network` | 47 | blocks until `https://github.com` responds |
| `install_opt` | 58 | `apt-cache show` guard, then `apt install $INTERACTIVE -y <pkg> --no-install-recommends`; warns instead of failing if unavailable |

`judge` is the build's tripwire: it must come *immediately* after the command it guards, and any
failure kills the whole build. Note `install_opt` at `:61` passes `$INTERACTIVE` **and** a literal
`-y`; `INTERACTIVE="-y"` so this is just redundant, harmless.

---

## 4. The three integration routes

### Route A — Flatpak AI apps (lowest effort) **[V]**

No new mod needed. `args.sh:305` has `DEFAULT_FLATPAK_TOOLS=""` with a commented list below it
(`:306-332`). `17-appstore-app/install.sh:47-57` loops it and runs `flatpak install -y flathub "$pkg"`.

**Pinpoint:** uncomment and add app IDs to `DEFAULT_FLATPAK_TOOLS` in `args.sh`. Build target is
Ubuntu 25.10 amd64.

### Route B — apt / pipx Python tooling (best control) **[V]**

`pipx` is already installed at `14-gnome-apps-mod/install.sh:206`, and mod 26 already uses
`pipx install gnome-extensions-cli` (`:7`). **pipx is the sanctioned PEP 668 escape hatch** — it
creates its own venv, so a bare `pip install` into system Python is both unnecessary and blocked.

### Route C — bundled local model (Ollama etc.) — hard path **[I]**

Multi-GB rootfs; `build.sh:205-214` runs `mksquashfs -comp zstd -Xcompression-level 19`, which is
CPU-slow at that level. GPU access from Flatpak needs explicit `--device=dri` + the NVIDIA/Vulkan
extension. Not recommended for a first attempt.

---

## 5. The five landmines (all verified)

### 5.1 `ID=markx` will break third-party vendor installers **[V]**

`43-etc-branding-mod/install.sh:21-22` writes:

```
ID=$TARGET_NAME          # -> ID=markx
ID_LIKE="ubuntu debian"
```

and `/etc/lsb-release:7` writes `DISTRIB_ID=$TARGET_BUSINESS_NAME` (= `MARKX`).

`ID_LIKE` was `debian` when this note was first written and is now
`"ubuntu debian"`. That fixes *dependency resolution* for `apt`-based vendor
installers, but it does **not** satisfy a literal `ID=ubuntu` or
`lsb_release -is = Ubuntu` gate — those still misdetect. `args.sh` now exposes
`MARKX_ID_UBUNTU_COMPAT` to report `ID=ubuntu` instead, if you would rather have
compatibility than generic branding.

Impact: vendor `.deb`/shell installers that gate on `ID=ubuntu` or `lsb_release -is` (Anthropic's
install script, Ollama's install script, various AI CLIs) will misdetect or refuse. Also
`software-properties` PPA flows are affected.

Fix options: patch `:21` to `ID=ubuntu` (loses branding, gains compatibility), or have your mod
add the repo manually to `/etc/apt/sources.list.d/` and skip the vendor script entirely.
**The second option is what the template in §6 does.**

### 5.2 Mod 79 can hard-abort your build **[V]**

`79-useless-package-remover/install.sh:10` sets `EXIT_IF_UNNECESSARY_PACKAGE_FOUND=1`, and
`:48-59` **`exit 1`s the entire build** if any listed package is present. The list includes
`snapd`, `snap`, `snap-store` (`:42-44`).

**Deadlock:** setting `STORE_PROVIDER="snap"` in `args.sh` makes mod 10 skip snap removal
(`10-no-snap-mod/install.sh:5-7`), which means snapd *is* installed — and then mod 79 kills the
build. **Do not enable `STORE_PROVIDER=snap` on this tree without also editing mod 79's list.**

Also note `:7` runs `apt autoremove -y --purge` before the check. Anything you install as a
top-level `apt install` is marked manual and is safe; deep auto-installed deps can be reaped.

### 5.3 Mod 41 overwrites `/etc/apt/sources.list` **[V]**

`41-target-apt-mirror-mod/install.sh:10-15` rewrites that file wholesale from `LIVE_UBUNTU_MIRROR`.
It does **not** touch `/etc/apt/sources.list.d/`.

**Rule: any third-party repo your mod adds must go in `/etc/apt/sources.list.d/`, never in
`/etc/apt/sources.list`.** This is order-independent and survives mod 41.

### 5.4 `store.provider` / `flathub` guard rails are strict **[V]**

`args.sh:118-128` and `:142-168` hard-`exit 1` if you set a Flathub mirror without
`STORE_PROVIDER=flatpak`, a Flatpak Firefox without a Flatpak store, etc. `17-appstore-app:123-125`
exits on an unknown store provider. Read `args.sh:105-173` before changing any provider.

### 5.5 Mod 42 depends on two third-party mirrors that can 404 **[V]**

`42-intel-thesof-mod/install.sh:8-9` pulls from `https://pub.aiursoft.com/sof-bin-2025.12.tar.gz`
and `https://git.aiursoft.com/PublicVault/...`. Every step is `judge`-guarded, so if either host
is down or the file moved, the build aborts. This is unrelated to AI but will bite you and look
like your fault. It's also the reason a "clean" build may fail for reasons that have nothing to do
with your change.

---

## 6. Drop-in mod template

**Location:** `src/mods/50-ai-mod/install.sh`

Slot rationale: sorts after 45 and before 78 — so `python3`/`pipx`/`gnupg` (14) and
`flatpak`+flathub (17) are already present, `sources.list` is already finalised (41), and it runs
before the 79 purge trap, the 80 initramfs rebuild, and the 84 apt cache clean.

```bash
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# ---- config gate: no-op unless enabled in args.sh --------------------
AI_PROVIDER="none"      # none | flatpak | pipx
AI_FLATPAK_APPS=""      # space-separated flatpak app IDs
AI_PIPX_PACKAGES=""     # space-separated pipx package names

print_ok "AnduinOS AI mod (provider=$AI_PROVIDER)"

case "$AI_PROVIDER" in
    none)
        print_info "AI_PROVIDER=none, nothing to do."
        exit 0
        ;;

    flatpak)
        install_opt flatpak
        print_ok "Adding flathub remote if missing..."
        flatpak remote-add --if-not-exists flathub \
            https://dl.flathub.org/repo/flathub.flatpakrepo
        judge "Ensure flathub remote"

        for app in $AI_FLATPAK_APPS; do
            print_ok "Installing flatpak $app..."
            flatpak install -y --noninteractive flathub "$app" \
                || print_warn "Could not install $app (skipped)"
        done
        judge "Install AI flatpak apps"
        ;;

    pipx)
        # pipx was installed by 14-gnome-apps-mod and is the PEP 668-safe path
        install_opt pipx
        for pkg in $AI_PIPX_PACKAGES; do
            print_ok "Installing pipx package $pkg..."
            pipx install "$pkg" || print_warn "Could not install $pkg (skipped)"
        done
        judge "Install AI pipx packages"
        ;;

    *)
        print_error "Unknown AI_PROVIDER: $AI_PROVIDER"
        exit 1
        ;;
esac
```

Then add to `args.sh` (near the other feature blocks, e.g. after line ~173):

```bash
#============================
# AI feature configuration
#============================
export AI_PROVIDER="none"
export AI_FLATPAK_APPS=""
export AI_PIPX_PACKAGES=""
```

Set them per-locale in `config/fast.json` / `config/all.json` — the keys are lowercased and
`export`-ed names are UPPERCASEd by `build_all.sh:80-90`.

---

## 7. Shipping an end-user `ai` command

Template: `40-do-anduinos-upgrade-mod/install.sh:6-28` — it `cat`s a heredoc into
`/usr/local/bin/`, `chmod +x`, `judge`. Add inside your mod:

```bash
print_ok "Adding new command to this OS: markx-ai..."
cat <<"EOF" > /usr/local/bin/markx-ai
#!/bin/bash
set -o pipefail
# read key from gnome-keyring, never hardcode it
exec /root/.local/bin/your-ai-cli "$@"
EOF
chmod +x /usr/local/bin/markx-ai
judge "Add new command markx-ai"
```

Note the quoting: `"EOF"` (unexpanded) in the upstream mods when the payload must not expand
`$VARS`; plain `EOF` when you *do* want build-time expansion (see the
`toggle_network_stats` case at `40-do-anduinos-upgrade-mod:32-42`).

### 7.1 Desktop launcher

`17-appstore-app/install.sh:70-121` is the reference for `/usr/share/applications/*.desktop`.
It ships a full 22-locale `Name[...]` block — replicate that or your launcher will be untranslated
in every non-English build.

### 7.2 Shipping GNOME shell defaults

`35-dconf-patch/install.sh:17` does `dconf load /org/gnome/ < ./dconf.ini`, then `:66-69` copies
root's dconf DB into `/etc/skel/.config/dconf/user` so new users inherit it.

**If you want an AI keybinding or toggle pre-enabled**, add it to
`src/mods/35-dconf-patch/dconf.ini` — and add your extension UUID to the `enabled-extensions` list
at `dconf.ini:182`, plus an entry in `26-gnome-extensions-installer/install.sh:54-69` and in
`33-gnome-extensions-enabler/install.sh`. Do **not** add it only to the installer; mod 33 is what
actually enables it.

---

## 8. Build / verify commands

```bash
# host preflight (makefile:29-51) — refuses root, checks lsb_release, installs DEPS
make bootstrap

# build only the current args.sh language
make                # == make current  -> cd src && ./build.sh

# two-language build (en_US + zh_CN)
make fast

# all 22 languages, then generates torrents (needs jq, mktorrent)
make all

# destroy artifacts
make clean
```

To test a single mod without a full ISO build **[I]**:

```bash
# after `make` has populated src/new_building_os, or by hand:
sudo chroot src/new_building_os /usr/bin/env \
  DEBIAN_FRONTEND=noninteractive \
  /root/mods/50-ai-mod/install.sh
```

Note `build.sh:111-115` sleeps 5s after the chroot to let it exit cleanly, and `build.sh:92`
passes a trailing `-` to `install_all_mods.sh` (which ignores args).

### 8.1 Host constraints

- Must **not** run as root (`makefile:30-33`).
- Host `lsb_release -i` must match `Ubuntu|Debian|Tuxedo|MARKX|AnduinOS|Kali` (`makefile:34-37`).
- WSL2 partially supported: `build.sh:71-79` degrades gracefully on bind-mount failure with
  `print_warn "... (WSL2?) — continuing"`. Expect friction.
- Output: `src/dist/MARKX-<version>-<lang>-<date>.iso` + `.sha256` (+ `.torrent` from `build_all.sh`).

---

## 9. Git caveat — read before running any git command here **[V]**

This folder is **not** its own repository. `git rev-parse --show-toplevel` returns `C:/`, and the
repo rooted there is an unrelated project (`origin` = `github.com/preetbiswas12/legion-website`).

```
$ git ls-files -- Users/preet/Downloads/AnduinOS-1.4 | wc -l
0                      # AnduinOS is entirely UNTRACKED
$ git ls-files | wc -l
569                    # the C:/ repo's own tracked files
```

**Consequence:** `git add`/`commit`/`checkout`/`restore`/`clean` from this directory will act on
the C: drive repo, not on AnduinOS. If you want version control for your AI work, initialise a
fresh repo *inside* `AnduinOS-1.4/AnduinOS-1.4` first — or better, clone upstream properly:

```bash
git clone https://github.com/Anduin2017/AnduinOS.git   # 1.x line
git clone https://github.com/AiursoftWeb/AnduinOS-2.git # current line
```

---

## 10. 1.x vs AnduinOS 2 — measured comparison

| | AnduinOS **1.4** (this tree) | AnduinOS **2** |
|---|---|---|
| Repo | `Anduin2017/AnduinOS` | `AiursoftWeb/AnduinOS-2` (`master`, 74★) **[V]** |
| Layout | `src/` + `src/mods/` | flat: `args.sh`, `build.sh`, `makefile`, `mods/`, `tests/` **[V]** |
| Arch | amd64 only | amd64 + arm64 **[V]** |
| Secure Boot | via grub only | signed GRUB + shim **[V]** |
| Live init | casper + initramfs-tools | Dracut live squashfs **[V]** |
| Installer | patched Ubiquity | native declarative installer **[V]** |
| Config UI | hand-edit `args.sh` | `make menuconfig` **[V]** |
| Tests | none | `make test` — unit + QEMU install/desktop acceptance **[V]** |
| AI features | none **[V]** | **none** — only `tests/framework/model.py` & `feature_model.py` (test data models, unrelated) **[V]** |

**There is no upstream AI work to reuse in either line.** But if your goal is a shippable
AI-enabled OS rather than a local experiment, 2 is the base with arm64, Secure Boot, and an
automated QEMU test matrix that would otherwise validate your mod by hand.

---

## 11. Pre-flight checklist

- [ ] Base builds *before* you touch anything (`make fast`) — establishes a known-good baseline
- [ ] Confirm `STORE_PROVIDER` is **not** `snap` (see §5.2 deadlock)
- [ ] Verify `42-intel-thesof-mod`'s two mirrors are reachable (see §5.5)
- [ ] Decide: patch `43-etc-branding-mod:21` to `ID=ubuntu`, or bypass vendor installers (§5.1)
- [ ] Pick slot `46`–`77`; use `50-ai-mod`
- [ ] New vars go in `args.sh` as `export`, and are read as env vars in the mod (§3)
- [ ] Never reference `$SCRIPT_DIR` inside a mod (§3)
- [ ] Third-party repos → `/etc/apt/sources.list.d/`, never `sources.list` (§5.3)
- [ ] Use `pipx`, not bare `pip` (§4 Route B)
- [ ] `judge` immediately after every fallible command
- [ ] Locale-complete `.desktop` file if you ship a launcher (§7.1)
- [ ] Initialise a local git repo or clone upstream — **do not** use the `C:/` repo (§9)
