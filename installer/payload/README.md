# Folderz 1.0

QML-only **My Files** popup and go/return buttons for reMarkable Paper Pro, firmware **3.28.0.172**, with XOVI and qt-resource-rebuilder.

**Folderz replaces Foldz.** The project was renamed from Foldz; this remains version 1.0.

**Author:** Nick Greenfield  
**Version:** 1.0  
**Licence:** GPL-3.0-or-later

## What it does

1. In any open document, a **folder** button appears at the **top right**, immediately **left of the Stickerz** sticker icon (Stickerz stays at `rightMargin: 120`; Folderz uses `220`).
2. Tap it: a popup lists the whole **My Files** tree (folders expandable, notebooks listed). The tree is read from the tablet's own xochitl `*.metadata` files.
3. Tap a notebook: Folderz remembers your current document and page on the long-lived navigator root, then opens the chosen notebook (via `navigator.explorer.open`, same path as a manual file-browser tap — restores that notebook's last page).
4. In the opened notebook, a **back-to-document** button (icon 4: left arrow + lined page) appears in the **same folder-button slot**. Tap it to return to the original notebook and page, then paste.
5. The clipboard survives the switch (same as Stickerz).

## Coexistence with Stickerz

**Separate `.qmd` file** (`folderz.qmd` beside `stickerz.qmd`). Preferable to merging into Stickerz because:

- Stickerz 1.0 is already confirmed working; a merge risks regressing it.
- Icon slots do not overlap (220 vs 120).
- State prefixes differ (`fld*` vs `stk*`) on the same navigator root.
- Either mod can be installed or removed alone.

If both return targets are set (e.g. you used Folderz to open the Stickers notebook), both back buttons can show in their own slots — Folderz at 220, Stickerz at 120.

## Icons

Drawn in QML with plain `Canvas` (no new hashes), black on white for e-ink:

| Button | Design |
|---|---|
| Open My Files | Folder with tab |
| Back | **4 — Back to document** (same as Stickerz): left arrow + lined page |

## Install on Windows

1. Run `Folderz-1.0-Setup.exe`. Windows SmartScreen may warn — choose **More info**, then **Run anyway**.
2. Enter the tablet IP (default `10.11.99.1`), username `root`, and the SSH password (never stored).
3. Choose **1** to install or update, or **2** to uninstall.
4. After install, in **reManager**: **rebuild the hashtab**, then **restart XOVI / xochitl**.  
   The installer does **not** restart the UI for you.

Upgrading from **Foldz** (`foldz.qmd`) or the earlier working name **Folder Project** (`folders.qmd`) is supported: `install.sh` moves those files into a backup first so only `folderz.qmd` loads (no duplicate icons).

### Manual (scp + ssh)

```
scp -r folderz-1.0 root@10.11.99.1:/home/root/folderz
ssh root@10.11.99.1
sh /home/root/folderz/install.sh
```

Then rebuild the hashtab and restart in reManager.

### What install.sh does

* Prints the firmware version.
* Backs up `exthome/qt-resource-rebuilder` to `/home/root/folderz-backup-<time>/` before changing anything.
* Moves a previous `foldz.qmd` (Foldz) or `folders.qmd` (Folder Project) into that backup so both mods do not load.
* Never overwrites a file it did not create (or that does not look like Folderz / Foldz / Folder Project).
* Leaves `stickerz.qmd` and every other mod alone.
* Installs `/home/root/xovi/exthome/qt-resource-rebuilder/folderz.qmd`.
* Records created paths in `/home/root/xovi/folderz.manifest`.

## Uninstall

```
sh /home/root/folderz/uninstall.sh
```

Afterwards, rebuild the hashtab and restart in reManager.

## Known limits and risks

* **Large libraries:** the popup reads every `*.metadata` file. A few hundred is fine; a few thousand may take several seconds (progress is shown). The UI loads in small batches so it should not freeze hard.
* **PDFs and ebooks:** they appear in the tree (DocumentType) and will open. Lasso-copy behaviour on PDFs/ebooks is whatever the firmware allows — stroke copy works best between notebooks.
* **Cloud-only / not downloaded:** opening fails with a short message ("not downloaded yet").
* **Trash:** deleted items and trash children are hidden.
* **XOVI tether:** if a hash fails to resolve, xochitl can crash-loop and the tablet reboots to stock. Run uninstall, rebuild hashtab, restart.
* **Nested folders:** supported (expand/collapse). Very deep trees are indented; very long names are elided.

## Evidence / provenance

* **AFFECT `8850026134298937527` / open-doc helper** and **AFFECT `11806562588218124596` / DocumentView overlay**: same targets as Stickerz 1.0 and alefaraci `linkFromSelection.qmd`.
* **`requestOpenDocumentOnPage`** `9497240032101537789`: linkFromSelection 3.28 / Stickerz (used for precise return-to-page).
* **`navigator.explorer.open`** `7712989590835962` / `6504147419`: navHistory 3.28 / ingatellent fourFingerSwipeForLastDoc (used when picking from the tree).
* **Library `entryForId`** `233694067165438` / `8399431778896295215`: linkFromSelection / navHistory 3.28.
* **Page jump** `7713405014271992` + enum path: linkFromSelection 3.28.
* **FolderListModel IMPORT** `180923.180930`, **folder** `7082663378949`, **count** `214622615378`, **get** `197086313`, **Name** `6502945418`: imageStickers / stickers 3.28.
* **XMLHttpRequest open/send** `6504147419` / `6504279475`, **JSON.parse** `6502785411`: linkFromSelection 3.28.
* Plain QtQuick types (`Item`, `Rectangle`, `MouseArea`, `Text`, `Timer`, `Canvas`, `Flickable`, `Column`, `Repeater`) are unhashed.

## Licence

GPL-3.0-or-later. Author: Nick Greenfield.

Credits: alefaraci (linkFromSelection, navHistory), ingatellent (FolderListModel / explorer.open patterns), FouzR / Stickerz 1.0 overlay pattern. XOVI and qt-resource-rebuilder: asivery.
