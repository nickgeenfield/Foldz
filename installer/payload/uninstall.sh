#!/bin/sh
# Removes only the files listed in the Folderz (and leftover Foldz / Folder Project) manifest.
set -eu
XOVI=/home/root/xovi
QMD_DIR=$XOVI/exthome/qt-resource-rebuilder
MANIFEST=$XOVI/folderz.manifest
PREV_MANIFEST=$XOVI/foldz.manifest
OLD_MANIFEST=$XOVI/folders.manifest

looks_like_ours() {
  grep -q "Folderz\|Foldz\|Folder Project\|fldLayer\|fldBackDoc" "$1" 2>/dev/null
}

if [ ! -f "$MANIFEST" ] && [ ! -f "$PREV_MANIFEST" ] && [ ! -f "$OLD_MANIFEST" ]; then
  removed=0
  for q in folderz.qmd foldz.qmd folders.qmd; do
    if [ -f "$QMD_DIR/$q" ] && looks_like_ours "$QMD_DIR/$q"; then
      rm -f -- "$QMD_DIR/$q"
      echo "Removed $QMD_DIR/$q (no manifest was present)."
      removed=1
    fi
  done
  if [ "$removed" = 1 ]; then
    echo "Now rebuild the hashtab and restart via reManager."
    exit 0
  fi
  echo "No Folderz / Foldz / Folder Project manifest found. Nothing removed."
  exit 0
fi

remove_listed() {
  mf=$1
  [ -f "$mf" ] || return 0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ -e "$f" ]; then rm -rf -- "$f"; echo "Removed $f"; else echo "Already gone: $f"; fi
  done < "$mf"
}

remove_listed "$MANIFEST"
remove_listed "$PREV_MANIFEST"
remove_listed "$OLD_MANIFEST"

# Belt-and-braces: leftover qmds if still present and look like ours
for q in folderz.qmd foldz.qmd folders.qmd; do
  if [ -f "$QMD_DIR/$q" ] && looks_like_ours "$QMD_DIR/$q"; then
    rm -f -- "$QMD_DIR/$q"
    echo "Removed leftover $QMD_DIR/$q"
  fi
done

rm -f "$MANIFEST" "$PREV_MANIFEST" "$OLD_MANIFEST"
echo "Now rebuild the hashtab and restart via reManager."
