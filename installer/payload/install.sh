#!/bin/sh
# Foldz 1.0 installer - My Files popup mod for reMarkable 3.28.
# QML only, no native .so. Run on the tablet as root from the unpacked folder.
# Does NOT restart the UI. Coexists with Stickerz (separate .qmd).
# Migrates cleanly over Folder Project 1.0 (folders.qmd) so only one icon loads.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
XOVI=/home/root/xovi
QMD_DIR=$XOVI/exthome/qt-resource-rebuilder
NEW_QMD=$QMD_DIR/foldz.qmd
OLD_QMD=$QMD_DIR/folders.qmd
MANIFEST=$XOVI/foldz.manifest
OLD_MANIFEST=$XOVI/folders.manifest
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP=/home/root/foldz-backup-$STAMP

fw=$(sed -n 's/^IMG_VERSION="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' /etc/os-release 2>/dev/null | head -n1)
[ -n "$fw" ] || fw=$(sed -n 's/^REMARKABLE_RELEASE_VERSION=//p' /usr/share/remarkable/update.conf 2>/dev/null | head -n1)
echo "Firmware: ${fw:-could not read /etc/os-release}"
case "$fw" in 3.28.*) ;; *) echo "WARNING: built for 3.28.x only. Press Ctrl-C now to stop, or Enter to continue anyway."; read _ ;; esac

[ -d "$QMD_DIR" ] || { echo "ERROR: $QMD_DIR not found - is XOVI + qt-resource-rebuilder installed?"; exit 1; }

# 1. Back up BEFORE changing anything
mkdir -p "$BACKUP"
tar -czf "$BACKUP/qt-resource-rebuilder.tar.gz" -C "$XOVI/exthome" qt-resource-rebuilder
ls -la "$XOVI/extensions.d" > "$BACKUP/extensions.d-listing.txt" 2>&1 || true
[ -f "$MANIFEST" ] && cp "$MANIFEST" "$BACKUP/foldz.manifest" || true
[ -f "$OLD_MANIFEST" ] && cp "$OLD_MANIFEST" "$BACKUP/folders.manifest" || true
echo "Backup written to $BACKUP"

is_ours() {
  f=$1
  grep -qx "$f" "$MANIFEST" 2>/dev/null && return 0
  grep -qx "$f" "$OLD_MANIFEST" 2>/dev/null && return 0
  return 1
}

drop_from_manifest() {
  mf=$1; path=$2
  [ -f "$mf" ] || return 0
  grep -vx "$path" "$mf" > "$mf.tmp" 2>/dev/null || true
  if [ -s "$mf.tmp" ]; then mv "$mf.tmp" "$mf"; else rm -f "$mf" "$mf.tmp"; fi
}

# 2. Refuse to overwrite foldz.qmd if we did not create it
if [ -e "$NEW_QMD" ] && ! is_ours "$NEW_QMD"; then
  if grep -q "Foldz\|Folder Project\|fldLayer\|fldBackDoc" "$NEW_QMD" 2>/dev/null; then
    echo "NOTE: replacing existing $NEW_QMD (looks like Foldz / Folder Project)."
  else
    echo "ERROR: $NEW_QMD exists but was not installed by Foldz / Folder Project. Not touching it."; exit 1
  fi
fi

# 3. Remove previous folders.qmd (Folder Project) so both mods do not load (no duplicate icons)
if [ -e "$OLD_QMD" ]; then
  if is_ours "$OLD_QMD" || grep -q "Folder Project\|Foldz\|fldLayer\|fldBackDoc" "$OLD_QMD" 2>/dev/null; then
    mv "$OLD_QMD" "$BACKUP/folders.qmd"
    echo "Moved previous $OLD_QMD to $BACKUP (so only Foldz loads)."
    drop_from_manifest "$OLD_MANIFEST" "$OLD_QMD"
    drop_from_manifest "$MANIFEST" "$OLD_QMD"
  else
    echo "ERROR: $OLD_QMD exists but was not installed by Folder Project / Foldz. Not touching it."; exit 1
  fi
fi

# 4. Install Foldz qmd (does not touch stickerz.qmd or any other mod)
: > "$MANIFEST.new"
cp "$HERE/src/foldz.qmd" "$NEW_QMD"
echo "$NEW_QMD" >> "$MANIFEST.new"
echo "Installed $NEW_QMD"
sort -u "$MANIFEST.new" > "$MANIFEST"; rm -f "$MANIFEST.new"

# Clear leftover folders.manifest (paths now tracked by foldz.manifest, or gone)
if [ -f "$OLD_MANIFEST" ]; then
  rm -f "$OLD_MANIFEST"
  echo "Cleared leftover folders.manifest (Foldz uses foldz.manifest)."
fi

if [ -f "$QMD_DIR/stickerz.qmd" ]; then
  echo "NOTE: Stickerz is also installed - Foldz sits to the LEFT of the Stickerz icon."
fi

cat <<MSG

Done. Foldz 1.0 is installed.
Now, in reManager:
  1. Rebuild the hashtab  (or run: $XOVI/rebuild_hashtable)
  2. Restart XOVI / xochitl  (or run: $XOVI/start)
This installer does NOT restart the UI for you.
A folder button appears top-right (left of Stickerz / the close area) in documents.
Tap it for a My Files popup; pick a notebook to open it; use the back icon to return.
If xochitl crash-loops, the tablet reboots to stock (XOVI is tethered) - then run ./uninstall.sh and restart.
MSG
