# NOTICE — Attribution and Licensing

## Upstream

MARKX is a fork and rebrand of **AnduinOS 1.4**.

| | |
|---|---|
| Upstream project | AnduinOS |
| Upstream repository | <https://github.com/Anduin2017/AnduinOS> |
| Upstream author | The AnduinOS team (Aiursoft) |
| Upstream website | <https://www.anduinos.com/> |
| Upstream licence | GPL-3.0 |
| Fork base | the `1.4` branch, `TARGET_BUILD_VERSION` 1.4.3 |

MARKX is **not affiliated with, endorsed by, or supported by** the AnduinOS team
or Aiursoft. The names "AnduinOS" and "Anduin" remain the property of their
respective owners and are used here only to credit the origin of this work.

## Licence position

Both upstream AnduinOS and this fork are licensed under the **GNU General
Public License v3**. The full text is in [`LICENSE`](./LICENSE).

The GPL-3.0 requires that:

- copyright notices and licence text are retained;
- source code remains available to recipients of binaries;
- derivative works are themselves distributed under the GPL-3.0.

Nothing in this rebrand removes or replaces any of those obligations. The
`LICENSE` file is unmodified from upstream.

## Third-party components that remain attributed

These are carried over from upstream and **must not be stripped**:

| Component | Author | Note |
|---|---|---|
| Fluent icon theme | vinceliuice | Sponsored by the AnduinOS team — see [OSS.md](./OSS.md) |
| Fluent GTK theme | vinceliuice | Sponsored by the AnduinOS team — see [OSS.md](./OSS.md) |
| ArcMenu | Ari Orgnl | |
| Dash to Panel | jderose9 | |
| GNOME Shell, GDM, Ubuntu base packages | GNOME / Canonical / Ubuntu | |
| `firmware-sof` (sof-bin) | thesofproject | Mirrors upstream `github.com/thesofproject/sof-bin`; fetched from `pub.aiursoft.com` at build time |
| `alsa-ucm-conf` | ALSA upstream | Fetched from `github.com/alsa-project` at build time |

`OSS.md` carries the full upstream list and is preserved verbatim.

## Trademarks

"Ubuntu" and "GNOME" are trademarks of Canonical Ltd. and the GNOME Foundation
respectively. Their use here is nominative — MARKX is a derivative work
distributed under the same terms as upstream and is neither endorsed by nor
affiliated with either organisation beyond that derivation.

## Build-time network dependencies inherited from upstream

These are **not** part of the licence position, but they are a practical
dependency: a MARKX build currently fetches assets from Aiursoft infrastructure.

| Used by | Host | Status |
|---|---|---|
| `42-intel-thesof-mod` (SOF audio firmware) | `pub.aiursoft.com` | **live** — the only remaining Aiursoft build fetch |
| `34-input-method-mod` (Rime IME) | `gitlab.aiursoft.com` | **403 / dead** — gated off by `CONFIG_IBUS_RIME="false"` |
| `24-fluent-icon-theme` | `github.com/vinceliuice` | upstream project, not Aiursoft |
| `25-fluent-gtk-theme` | `github.com/vinceliuice` | upstream project, not Aiursoft |
| `42-intel-thesof-mod` (`alsa-ucm-conf`) | `github.com/alsa-project` | upstream project, not Aiursoft |
| `18-firefox-mod` | `packages.mozilla.org` | Mozilla's own APT repo (was `mirror-ppa.aiursoft.com`) |
| `22-ubiquity-patch` installer slides | — | links only, no fetch; now points at the MARKX repo |

`src/repair.sh` previously fetched `gitlab.aiursoft.com/anduin/init-server` at
runtime and piped it into `bash`. That dependency has been removed.

If Aiursoft withdraws `pub.aiursoft.com`, the SOF firmware fetch at mod 42 is the
one thing that will break. Every other build-time URL now resolves to either a
first-party host or the upstream project's own repository.
