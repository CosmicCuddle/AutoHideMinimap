#!/usr/bin/env python3
"""Build an installable review-only ZIP for Auto Hide Minimap 1.3.0.

Does not tag, publish, alter SavedVariables, or contact GitHub.
"""
from __future__ import annotations

import hashlib
import re
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]
VERSION = "1.3.0"
FILES = (ROOT / "AutoHideMinimap.toc", ROOT / "AutoHideMinimap.lua")
TARGET = ROOT / "dist" / "AutoHideMinimap-v1.3.0-REVIEW.zip"


def build() -> str:
    toc, lua = (path.read_text(encoding="utf-8") for path in FILES)
    assert re.search(r"^## Interface: 30300$", toc, re.M), "Wrong WoW interface"
    assert re.search(r"^## Version: 1\.3\.0$", toc, re.M), "Wrong TOC version"
    assert re.search(r"^## SavedVariables: AutoHideMinimapDB$", toc, re.M), "SavedVariables ID changed"
    assert toc.strip().endswith("AutoHideMinimap.lua"), "Wrong addon load path"
    assert "Auto Hide Minimap v1.3.0" in lua, "Wrong Lua version"
    assert "AutoHideMinimapDB.autoHideEnabled" in lua, "Missing saved option"
    assert all(path.is_file() and not path.is_symlink() for path in FILES)

    TARGET.parent.mkdir(exist_ok=True)
    with ZipFile(TARGET, "w") as archive:
        for path in sorted(FILES, key=lambda p: p.name):
            entry = ZipInfo(f"AutoHideMinimap/{path.name}", (2020, 1, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, path.read_bytes(), compress_type=ZIP_DEFLATED)

    with ZipFile(TARGET) as archive:
        names = archive.namelist()
        assert len(names) == 2, "Unexpected files"
        assert set(names) == {
            "AutoHideMinimap/AutoHideMinimap.lua",
            "AutoHideMinimap/AutoHideMinimap.toc",
        }, "Invalid addon folder/contents"
        assert archive.testzip() is None, "Corrupted ZIP"
        assert not any("WTF" in n or "SavedVariables" in n for n in names), "Personal data leak"

    digest = hashlib.sha256(TARGET.read_bytes()).hexdigest()
    print(f"PASS: v{VERSION} installable review ZIP contains exactly Lua + TOC")
    print(f"SHA256: {digest}")
    (ROOT / "dist" / "SHA256SUMS.txt").write_text(
        f"{digest}  {TARGET.name}\n", encoding="ascii"
    )
    return digest


if __name__ == "__main__":
    build()
