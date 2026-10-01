#!/bin/bash
# Preflight check for building MARKX inside WSL. Run AFTER copying to ~/markx.
cd ~/markx || { echo "FAIL: ~/markx not found — copy the tree first"; exit 1; }

echo "=== 1. host check (makefile:34 whitelist) ==="
lsb_release -i 2>/dev/null | grep -qE "(Ubuntu|Debian|Tuxedo|MARKX|AnduinOS|Kali)" \
  && echo "OK   host is whitelisted" \
  || echo "FAIL host not whitelisted by makefile"

echo
echo "=== 2. running as root? (build must NOT be root) ==="
[ "$(id -u)" -eq 0 ] && echo "FAIL you are root" || echo "OK   uid=$(id -u)"

echo
echo "=== 3. build deps ==="
missing=""
for p in binutils debootstrap squashfs-tools xorriso grub-pc-bin \
         grub-efi-amd64 grub2-common mtools dosfstools; do
  dpkg -s "$p" >/dev/null 2>&1 || missing="$missing $p"
done
if [ -n "$missing" ]; then echo "MISSING:$missing"; else echo "OK   all 9 present"; fi

echo
echo "=== 4. brand assets present (the ones we regenerated) ==="
for f in src/mods/19-plymouth-patch/logo_128.png \
         src/mods/19-plymouth-patch/markx_text.png \
         src/mods/35-dconf-patch/markx_text_smaller.png \
         src/mods/36-ubuntu-logo-text/ubuntu-logo-text.png \
         src/mods/36-ubuntu-logo-text/ubuntu-logo-text-dark.png; do
  [ -f "$f" ] && echo "OK   $f" || echo "FAIL $f  <-- install.sh will cp: cannot stat"
done

echo
echo "=== 5. install.sh sources resolve (19-plymouth-patch) ==="
grep -oE '\./[a-zA-Z0-9_.-]+\.png' src/mods/19-plymouth-patch/install.sh | sort -u | while read -r r; do
  [ -f "src/mods/19-plymouth-patch/${r#./}" ] \
    && echo "OK   $r" || echo "FAIL $r"
done

echo
echo "=== 6. args.sh URL guard ==="
if bash -c 'set -u; source ./src/args.sh' >/dev/null 2>&1; then
  echo "OK   args.sh sourced, branding URLs resolved"
else
  echo "FAIL args.sh guard tripped — check TARGET_*_URL in src/args.sh"
fi

echo
echo "=== 7. no residual curl|bash in shipped scripts ==="
grep -rn 'curl.*|.*bash' src/repair.sh src/mods/ 2>/dev/null \
  && echo "FAIL remote code execution still present" \
  || echo "OK   none found"

echo
echo "=== 8. shell syntax across build scripts ==="
bad=0
for f in src/build.sh src/shared.sh src/repair.sh makefile build_all.sh; do
  bash -n "$f" 2>/dev/null || { echo "FAIL syntax: $f"; bad=1; }
done
[ $bad -eq 0 ] && echo "OK   all parse clean"

echo
echo "=== 9. disk space ==="
df -h ~ | tail -1
echo "(build needs ~20G scratch in src/new_building_os)"

echo
echo "=== 10. base OS still served? (questing EOL check) ==="
code=$(curl -s -o /dev/null -w '%{http_code}' \
  http://archive.ubuntu.com/ubuntu/dists/questing/Release)
echo "archive.ubuntu.com questing/Release -> HTTP $code"
[ "$code" = "200" ] && echo "OK   debootstrap should work" || echo "WARN not serving — build will fail"
