#!/usr/bin/env bash
# Checks that the 64-bit native libraries in an AAB or APK are ELF-aligned for 16 KB memory pages
# (every LOAD segment alignment >= 0x4000). Needs: unzip, readelf (binutils).
#
#   tool/check_16kb_alignment.sh build/app/outputs/bundle/release/app-release.aab
#
# Exit 1 on any misaligned library; prints library paths only. APK zip alignment is a separate check:
#   zipalign -c -P 16 -v 4 app.apk
set -euo pipefail

PKG="${1:?usage: $0 <app.aab|app.apk>}"
[ -f "$PKG" ] || { echo "ERROR: $PKG not found"; exit 2; }
command -v readelf >/dev/null || { echo "ERROR: readelf (binutils) is required"; exit 2; }

tmp="$(mktemp -d)"
unzip -q -o "$PKG" '*/lib/*' 'lib/*' -d "$tmp" 2>/dev/null || true

checked=0; bad=0
while IFS= read -r so; do
  case "$so" in */arm64-v8a/*|*/x86_64/*) ;; *) continue ;; esac   # only 64-bit ABIs need 16 KB
  checked=$((checked + 1))
  min=$(readelf -lW "$so" 2>/dev/null | awk '$1=="LOAD" {print $NF}' | sort | head -n1)
  if [ -z "$min" ]; then echo "UNREADABLE: ${so#"$tmp"/}"; bad=$((bad + 1)); continue; fi
  if [ $((min)) -lt 16384 ]; then
    echo "NOT 16 KB ALIGNED (align $min): ${so#"$tmp"/}"; bad=$((bad + 1))
  fi
done < <(find "$tmp" -name '*.so' | sort)

echo "Native libraries checked (arm64-v8a/x86_64): $checked, misaligned: $bad"
[ "$checked" -gt 0 ] || { echo "ERROR: no 64-bit .so found; is this the right file?"; exit 2; }
[ "$bad" -eq 0 ]
