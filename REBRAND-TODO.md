# REBRAND-TODO — MARKX

Tracked list of what still needs doing before a MARKX build is shippable.
Ordered by how likely it is to break a build.

Legend: `[ ]` open · `[x]` done · `[!]` blocked on a decision

---

## 1. Placeholder values — addressed, verify before release

URLs now derive from two variables in `args.sh:104-105`:

```bash
export MARKX_GITHUB_OWNER="preetbiswas12"
export MARKX_GITHUB_REPO="Mark-x"
```

All eight `TARGET_*_URL` values are built from those. A guard block
(`args.sh:139-171`) hard-fails the build if any URL is still empty or contains
`example.org` / `example.com` / `markx-os`. Override with
`MARKX_BRANDING_CHECK=false` for local throwaway builds only.

The guard was exercised directly rather than assumed: `args.sh` sources cleanly
with the current values, all eight URLs are accepted, and `example.org`,
`example.com`, `markx-os` and the empty string are each rejected. The sibling
asset-URL guard was likewise tested — the three real GitHub archive URLs pass
and a `&` query string fails.

- [x] Confirm `MARKX_GITHUB_OWNER` / `MARKX_GITHUB_REPO` are the real
      repository, and that it exists and is public
      — verified via the GitHub API on 2026-10-01: `preetbiswas12/Mark-x`
      exists, is public, `default_branch = main`. The original value was
      `markx` (no hyphen), which 404s; corrected to `Mark-x`. That change
      alone was not enough — 63 hardcoded `github.com/preetbiswas12/markx`
      links across the installer slides also had to be corrected.
- [ ] `TARGET_UPGRADE_URL_BASE` and `TARGET_DOWNLOAD_URL_BASE` both point at
      GitHub Releases. GitHub serves arbitrary paths under
      `/releases/download/<tag>/...` but **not** the `<base>/<version>/<file>`
      path shape these scripts append. If autorepair/upgrade must work, you
      need a real static host (Cloudflare R2, S3, Netlify) and a rewrite —
      currently these will 404 at runtime
- [ ] Add a `PRIVACY.md` to the repo, or point `TARGET_PRIVACY_URL` elsewhere
- [ ] Create `docs/` in the repo, or point `TARGET_DOCS_URL` elsewhere.
      **The installer's Help slide now links to this URL too**, so a dead link
      there is user-facing rather than merely cosmetic

### Link status verified against the pushed repo (2026-10-01)

Source tree pushed to `main` as `ab4d00d`. Each link below was probed
through the GitHub API rather than assumed:

| Link | Where it ships | Status |
|---|---|---|
| `<repo>` | `HOMEPAGE` / `TARGET_HOME_URL` | 200 |
| `blob/main/LICENSE` | ISO README | 200 — only because of the fallback below |
| `issues` | `BUG_REPORT_URL` | 200 |
| `discussions` | `SUPPORT_URL` in `/etc/os-release` | **404** — repo reports `has_discussions: false` |
| `tree/main/docs` | Help slide ×21 langs, app-store Help, ISO README | **404** — no `docs/` |
| `blob/main/PRIVACY.md` | `PRIVACY_URL` in `/etc/os-release` | **404** — no `PRIVACY.md` |
| `releases/download` | `markx upgrade`, `do-anduinos-autorepair` | **404** — repo has 0 releases |

`SUPPORT_URL` is the cheapest fix and needs no code: repository *Settings →
Features → enable Discussions*. The other three need content written or a
different target URL.

`TARGET_BUILD_BRANCH` was also calling `git rev-parse` unguarded. On the WSL
build host (`~/markx` is not a git checkout) that exits 128, leaving the
variable empty and rendering the ISO README's license link as
`.../blob//LICENSE`. It now falls back to `main`.

---

## 2. Blocking — assets still carry the AnduinOS wordmark

Files were renamed to MARKX names and all code references updated, but the
**image content is still the AnduinOS logo and wordmark**. Replace the pixels:

- [ ] `src/mods/19-plymouth-patch/markx_text.png` — boot splash watermark
- [ ] `src/mods/19-plymouth-patch/logo_128.png` — boot splash fallback
All of these files **exist and are wired in** — every code reference points at
them. The boxes below are ticked for *presence*, not *appearance*: no human has
yet confirmed the art renders correctly (aspect ratio, contrast, whether it is
the mark you actually want). **That visual check is yours to do.**

- [x] `src/mods/19-plymouth-patch/markx_text.png` — boot splash watermark (248x87)
- [x] `src/mods/19-plymouth-patch/logo_128.png` — boot splash fallback (128x128)
- [x] `src/mods/35-dconf-patch/markx_text_smaller.png` — GDM greeter logo (124x44)
- [x] `src/mods/36-ubuntu-logo-text/ubuntu-logo-text.png` — boot menu text, light ink (400x110)
- [x] `src/mods/36-ubuntu-logo-text/ubuntu-logo-text-dark.png` — boot menu text, dark ink (400x110)
- [x] `screenshot.png` — repo screenshot
- [ ] `src/mods/30-gnome-extension-arcmenu-patch/markx-logo.svg` — ArcMenu start-button icon (**most visible**) — present, but its state has not been verified against your master art

> The `36-ubuntu-logo-text/` filenames are **intentionally not renamed** — they
> mirror the destination path `/usr/share/pixmaps/ubuntu-logo-text.png`. Only
> their contents need replacing.

Also visible in the build — **none of these images has been replaced yet.**
The slide *text* is rebranded (see §Fixed below); the *images* are still upstream's:

- [ ] `src/mods/22-ubiquity-patch/slides/screenshots/` — installer slide images
      (`welcome.png`, `gaming.png`, `jb.png`, `pv.png`, `sc.png`, `st.png`)
- [ ] `src/mods/22-ubiquity-patch/slides/link/background.png` — slide backdrop
      (not in `screenshots/`, as an earlier revision of this list implied)
- [ ] `src/mods/23-wallpaper-mod/Fluent-building-light.png`,
      `Fluent-building-night.png` — wallpapers

---

## 3. Build-time dependencies on third-party infrastructure

Only **one** Aiursoft host is still used at build time. See
[NOTICE.md](./NOTICE.md) for the full table.

- [ ] `42-intel-thesof-mod` → `pub.aiursoft.com/sof-bin-2025.12.tar.gz` —
      **the only remaining Aiursoft fetch.** Alive today (HTTP 200). Mitigation:
      mirror the tarball into your own repo and change `SOF_BIN_LINK` at
      `install.sh:8`. The GitHub release noted at `install.sh:7` is the upstream
      original.

Resolved since the fork:

- [x] `24-fluent-icon-theme` — now `github.com/vinceliuice/Fluent-icon-theme`
      (was `git.aiursoft.com/PublicVault/...`, which now 403s)
- [x] `25-fluent-gtk-theme` — now `github.com/vinceliuice/Fluent-gtk-theme`
- [x] `42-intel-thesof-mod` (`alsa-ucm-conf`) — now `github.com/alsa-project`
- [x] `args.sh` `BUILD_FIREFOX_MIRROR` / `LIVE_FIREFOX_MIRROR` — no longer used.
      `FIREFOX_PROVIDER="official_apt"` installs from `packages.mozilla.org`,
      Mozilla's own APT repo. The mozillateam PPA ships an empty index for
      `questing`, and its Aiursoft mirror serves the same empty index.
- [x] `22-ubiquity-patch` installer slides — no longer link to
      `gitlab.aiursoft.com`; links now point at the MARKX repo

Still referenced but disabled:

- [ ] `34-input-method-mod` → `gitlab.aiursoft.com/anduin/anduinos-rime`
      returns **403**, but the block is gated behind `CONFIG_IBUS_RIME="false"`
      so the build never reaches it. Leave that config alone, or replace the URL
      before enabling Rime.

---

## 4. Security — `src/repair.sh` remote code execution — fixed

Was `src/repair.sh:223`:

```bash
curl -s https://gitlab.aiursoft.com/anduin/init-server/-/raw/master/mirror.sh?ref_type=heads | bash
```

This piped an unauthenticated script from a third-party domain into `bash` on
every `REPAIR.sh` run, and `REPAIR.sh` is copied into the live ISO by
`src/build.sh:135` — so it shipped to every user.

**Now:** replaced with a local, deterministic `sources.list` write. Defaults to
`http://archive.ubuntu.com/ubuntu/`, overridable via `MARKX_APT_MIRROR` in
`/etc/markx/apt-mirror.conf`. The mirror string is validated against
`^https?://[A-Za-z0-9._~:/?@%+=,-]+$` before being written to a root-owned
file, and cleartext HTTP to anything other than `*.archive.ubuntu.com` prompts
for confirmation.

- [x] Remote `curl | bash` removed
- [ ] Decide whether to also drop the interactive prompt (it breaks
      unattended repair runs) or keep it as a safety gate

---

## 5. Deliberately not renamed — do not "fix" these

| Item | Why |
|---|---|
| `switcher@anduinos`, `noti-bottom-right@anduinos`, `loc@anduinos.com` | GNOME extension UUIDs. Renaming breaks extension identity and update resolution. Listed in `dconf.ini:182`, `33-gnome-extensions-enabler:15`, `29-gnome-extension-anduinos-loc:6`. |
| `29-gnome-extension-anduinos-*`, `40-do-anduinos-*` directory names | Cosmetic only. Safe to rename for tidiness, but nothing depends on it. |
| `40-do-anduinos-*` command names (`do_anduinos_upgrade`) | Shipped CLI names. Renaming breaks muscle memory and docs; `upgrade_14_to_20.sh` also references them. |
| `upgrade_14_to_20.sh` | This is the **upstream AnduinOS 1.4 → 2.0** upgrade path. It would upgrade a MARKX install to upstream AnduinOS 2.0, discarding the fork. **Consider deleting it.** It is currently unreferenced by the build (`build.sh` copies `repair.sh`, not `upgrade.sh`). |
| `src/upgrade.sh` | Same problem, plus it hardcodes `DISTRIB_ID=AnduinOS` so it now fails its own guard. Dead code. |

---

## 6. Decisions pending

- [ ] **Codename.** `TARGET_CODENAME` currently defaults to
      `$TARGET_UBUNTU_VERSION` (`questing`), so `/etc/os-release` reports
      `VERSION_CODENAME=questing`. Set a real codename if you want one.
- [ ] **`MARKX_ID_UBUNTU_COMPAT`.** Currently `false`, so `/etc/os-release`
      reports `ID=markx` with `ID_LIKE="ubuntu debian"`. Set to `true` if vendor
      AI installers (Anduin, Ollama, others) refuse to run.
- [ ] **`TARGET_BUILD_VERSION`.** Reset to `1.0.0` during the rebrand. Confirm
      this is the version you want to ship.
- [ ] **Git.** This tree is **untracked** inside an unrelated repo rooted at
      `C:/` (`origin` = `preetbiswas12/legion-website`). There is no undo.
      Initialise a real repo or clone upstream properly before further work.

---

## 7. Optional — base OS

The build targets **Ubuntu 25.10 `questing`**, which is past end-of-life
(no security updates since ~July 2026). Verified still on
`archive.ubuntu.com` and served without a `Valid-Until` field, so `debootstrap`
still works — but it will eventually be relocated to `old-releases.ubuntu.com`.

Current Ubuntu is **26.04 `resolute`**, which is what AnduinOS 2 targets
(`upgrade_14_to_20.sh` installs `base-files/resolute-addon`).

- [ ] Stay on `questing` for a faithful 1.4 fork
- [ ] Move `TARGET_UBUNTU_VERSION` to `resolute` and fix what breaks

Note `14-gnome-apps-mod:94-101` already special-cases `jammy|noble` for
`wireless-tools`; expect more version-gated breakage if you move up.

---

## Fixed in the 2026-10-01 audit

A full-tree sweep for `anduinos` (case-insensitive, **every** file type) found
**195 files / 754 hits**. An earlier pass had filtered on `*/install.sh` and so
missed HTML, SVG, JS and desktop assets entirely — this section is the corrected
picture.

### Installer slides — the most visible leak

`src/mods/22-ubiquity-patch/slides/` alone accounted for **148 files / 502
hits**. The installer would have greeted every new user with "Welcome to
AnduinOS", pointed the GPL source-code text at `gitlab.aiursoft.com` (403, dead),
and sent Docs / community / home links to upstream. Now:

| Was | Now |
|---|---|
| `https://www.anduinos.com/` ×21 | `https://github.com/preetbiswas12` |
| `https://docs.anduinos.com/` ×21 | `…/preetbiswas12/markx/tree/main/docs` |
| `https://github.com/Anduin2017/AnduinOS/discussions` ×21 | `…/preetbiswas12/markx/discussions` |
| `https://gitlab.aiursoft.com/anduin/anduinos` ×21 | `…/preetbiswas12/markx` |
| 418 prose `AnduinOS` occurrences | `MARKX` |

URLs were substituted **before** the token swap — otherwise
`Anduin2017/AnduinOS/discussions` would have become `Anduin2017/MARKX/discussions`.
Verified: 0 hits remain, `<p>` tag balance unchanged, 148 files in and 148 out.

### Shell logic

- [x] `mods/16-localization-patch/install.sh:96` — used `[ … =~ … ]` rather than
      `[[ … ]]`. `test` has no `=~` operator, so it died with
      `[: too many arguments` (exit 2) and the **baobab localization block never
      ran** — despite `baobab` being listed in `DEFAULT_APPS`. Its four siblings
      (lines 6, 51, 141, 183) were already correct.

### Other rebrand leaks

- [x] `mods/42-gnome-sessions-patch` — wrote `Name=AnduinOS` into both
      wayland-session files and renamed them to `anduinos*.desktop`. This is the
      **session name shown in GDM's gear menu**. Now `MARKX` / `markx*.desktop`.
- [x] `mods/17-appstore-app` — `Comment=…AnduinOS…` in 15 languages, displayed
      as the hover tooltip on "Apps Store"; file was `anduinos-software.desktop`.
      Now `MARKX` / `markx-software.desktop`. Two grammar joins the token swap
      broke were hand-corrected: French `d'AnduinOS` → `de MARKX`, Turkish
      `AnduinOS'un` → `MARKX'ın`.
- [x] `mods/27-dash-to-panel-patch` — the marker written into shipped JS **and**
      the `grep` that verifies it were both updated, so they still match.
- [x] `mods/23-software-properties-common-patch` — `anduinos.info`/`.csv` →
      `markx.*`, which now actually matches `ID=markx`.
- [x] `src/repair.sh` — user-facing error strings, plus internal mount points
      (`/mnt/anduinos_squashfs` → `/mnt/markx_squashfs`) and `/tmp/*.log` names.
      52 hits → 3, all three whitelisted per §5.
- [x] `makefile:1`, `07-system-tools-install-mod:105` — comments.

**What the sweep still reports, deliberately:** `LICENSE` (GPL copyright — must
never be touched); upstream attribution in `README.md`/`NOTICE.md`/`OSS.md`
(required, see NOTICE); the §5 whitelisted names; `upgrade_14_to_20.sh` and
`src/upgrade.sh` (dead code, §5); and the compiled `.mo` binaries under
`29-gnome-extension-anduinos-loc`, which cannot be text-edited and are covered
by the §5 UUID exemption.

---

## Done

- [x] `args.sh` — `TARGET_NAME`, `TARGET_BUSINESS_NAME`, version, codename hook
- [x] `args.sh` — added `MARKX` branding, URL, and `MARKX_AI_*` variables
- [x] `43-etc-branding-mod` — URLs and codename driven from config
- [x] `43-etc-branding-mod` — `ID_LIKE="ubuntu debian"` added so vendor
      installers resolve dependencies correctly
- [x] `build_all.sh` — hardcoded `AnduinOS-*` globs parameterised (was silently
      producing zero torrents after a rebrand)
- [x] `build_all.sh` — hard-fails if no torrents are generated
- [x] `build_all.sh` — validates `TARGET_BUSINESS_NAME` is readable
- [x] `makefile` — host whitelist accepts `MARKX`
- [x] `src/build.sh` — ISO README links driven from config
- [x] `40-do-anduinos-upgrade-mod` — upgrade URL driven from config
- [x] `40-do-anduinos-autorepair-mod` — templated at install time, with a
      post-install check that fails the build if upstream references survive
- [x] `17-appstore-app` — store link driven from config
- [x] Brand assets renamed; all code references updated
- [x] `50-markx-mod` created — CLI, `/etc/markx` config, `.desktop` launcher
- [x] `README.md`, `NOTICE.md` rewritten
- [x] `LICENSE` and `OSS.md` left untouched (GPL + vinceliuice attribution)
- [x] `upgrade_14_to_20.sh` left untouched (flagged, not deleted)
- [x] `args.sh` — branding guard (`MARKX_URL_VARS`) and asset-URL guard both
      **exercised**: good URLs pass, `example.org`/`example.com`/`markx-os` and
      empty values are rejected, and a `&` query string fails the asset pattern
- [x] `args.sh` — third-party asset URLs (`FLUENT_ICON_THEME_URL`,
      `FLUENT_GTK_THEME_URL`, `ALSA_UCM_CONF_URL`) lifted out of the mods so
      they are configurable in one place
- [x] `FIREFOX_PROVIDER="official_apt"` — installs from `packages.mozilla.org`.
      The mozillateam PPA ships a 20-byte empty `Packages.gz` for `questing`,
      and its Aiursoft mirror serves the same empty index
- [x] `build.sh` — `run_chroot` pins `PATH` rather than inheriting the host
      sudoers `secure_path`, which omits `/usr/local/bin` and made `markx`
      invisible to the post-install verification
- [x] `50-markx-mod` — a backtick inside an unquoted heredoc was executing
      `` `markx setup` `` at build time and eating its own usage text
- [x] `sync.sh` — whole-tree sync. The previous hand-maintained file list had
      silently gone stale and omitted `build.sh` and mod 50
- [x] `mods/16-localization-patch`, `17-appstore-app`,
      `23-software-properties-common-patch`, `27-dash-to-panel-patch-mod`,
      `42-gnome-sessions-patch` — see *Fixed in the 2026-10-01 audit* above
