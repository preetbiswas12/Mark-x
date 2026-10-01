# MARKX

**M**odular **A**rtificial **R**easoning **K**ernel — e**X**tended

An Ubuntu-based Linux distribution with a first-party local AI reasoning layer,
designed to offer a familiar and easy-to-use desktop for anyone moving to Linux.

> **This is a fork of [AnduinOS](https://github.com/Anduin2017/AnduinOS) 1.4**, the
> upstream project by the AnduinOS team. MARKX is not affiliated with or endorsed by
> them. See [NOTICE.md](./NOTICE.md) for the full attribution and licensing position.

<img align="right" width="100" height="100" src="./src/mods/30-gnome-extension-arcmenu-patch/markx-logo.svg">

## What is MARKX

Two things ship in one image:

1. **A desktop.** GNOME with ArcMenu, Dash-to-Panel, Fluent icon/GTK themes and
   a patched Ubuntu installer — the familiar AnduinOS layout, aimed at people
   coming from Windows.
2. **A reasoning kernel.** The `markx` CLI, an `/etc/markx` config file, and a
   desktop launcher. Local model *weights* are deliberately **not** bundled — see
   [AI layer](#ai-layer) for why.

## The name

`Modular Artificial Reasoning Kernel - eXtended`. The capital **X** in **MARKX**
does double duty: it closes `MAR-K` and opens `-eXtended`.

There is a pre-existing project on npm also called `markx` (a Markdown
highlighter). This project claims the **PyPI** name and the AI/distro
namespace, not the Markdown one. PyPI was verified available at the time of
writing.

## Build

Building on MARKX or a supported Ubuntu/Debian/Tuxedo/Kali host is recommended.
The build host must not be root, and an internet connection is required.

```bash
make
```

The ISO is written to `./src/dist`.

| Command | Effect |
|---|---|
| `make` | Build the current language (see `src/args.sh`) |
| `make all` | Build every language in `config/all.json` |
| `make fast` | Build `en_US` + `zh_CN` only |
| `make clean` | Remove build artifacts |
| `make bootstrap` | Validate the host and install build dependencies |

All build parameters live in **`./src/args.sh`** — base Ubuntu release, mirrors,
version, timezone, bundled apps, and the `MARKX_*` AI settings. Per-language
overrides live in `./config/*.json`.

## AI layer

The AI component is installed by `src/mods/50-markx-mod/` and is configured from
`args.sh`:

```bash
export MARKX_AI_PROVIDER="none"      # none | flatpak | pipx
export MARKX_AI_FLATPAK_APPS=""      # flatpak app IDs
export MARKX_AI_PIPX_PACKAGES=""     # pipx package names
```

`pipx` is the recommended path for Python tooling — it builds isolated venvs and
sidesteps PEP 668's `externally-managed-environment` block on system Python.

**No model weights are bundled.** A multi-GB payload would make the
`mksquashfs -Xcompression-level 19` step in `src/build.sh` prohibitively slow and
would leave users pinned to a stale model. Instead:

```bash
markx status   # show config and detect installed backends
markx setup    # print backend installation instructions
markx run      # start a local inference session
```

## Before you ship a build

This tree is a rebrand of an existing project, and several things still need
attention. See [REBRAND-TODO.md](./REBRAND-TODO.md) for the tracked list — most
importantly the remaining image assets, the `questing` base release going EOL,
and the one surviving build-time dependency on `pub.aiursoft.com`.

## License

MARKX is released under the **GNU General Public License v3** — see
[LICENSE](./LICENSE).

The upstream AnduinOS project is also GPL-3.0. The open-source software included
in this distribution is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY. [List of third-party software included in MARKX](OSS.md).

The Fluent icon and GTK themes are by
[vinceliuice](https://github.com/vinceliuice), who is sponsored by the AnduinOS
team. That attribution is preserved in [OSS.md](OSS.md) and must not be removed.
