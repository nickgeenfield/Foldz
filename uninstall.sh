#!/bin/sh
# Removes only the files listed in the Foldz (and leftover Folder Project) manifest.
set -eu
XOVI=/home/root/xovi
QMD_DIR=$XOVI/exthome/qt-resource-rebuilder
MANIFEST=$XOVI/foldz.manifest
OLD_MANIFEST=$XOVI/folders.manifest

if [ ! -f "$MANIFEST" ] && [ ! -f "$OLD_MANIFEST" ]; then
  removed=0
  for q in foldz.qmd folders.qmd; do
    if [ -f "$QMD_DIR/$q" ] && grep -q "fldLayer\|fldBackDoc\|Foldz\|Folder Project" "$QMD_DIR/$q" 2>/dev/null; then
      rm -f -- "$QMD_DIR/$q"
      echo "Removed $QMD_DIR/$q (no manifest was present)."
      removed=1
    fi
  done
  if [ "$removed" = 1 ]; then
    echo "Now rebuild the hashtab and restart via reManager."
    exit 0
  fi
  echo "No Foldz / Folder Project manifest found. Nothing removed."
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
remove_listed "$OLD_MANIFEST"

# Belt-and-braces: leftover qmds if still present and look like ours
for q in foldz.qmd folders.qmd; do
  if [ -f "$QMD_DIR/$q" ] && grep -q "fldLayer\|fldBackDoc\|Foldz\|Folder Project" "$QMD_DIR/$q" 2>/dev/null; then
    rm -f -- "$QMD_DIR/$q"
    echo "Removed leftover $QMD_DIR/$q"
  fi
done

rm -f "$MANIFEST" "$OLD_MANIFEST"
echo "Now rebuild the hashtab and restart via reManager."
