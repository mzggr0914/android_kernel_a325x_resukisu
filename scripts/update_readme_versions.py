#!/usr/bin/env python3
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KSU = ROOT / "KernelSU"
START = "<!-- AUTO:RESUKISU:START -->"
END = "<!-- AUTO:RESUKISU:END -->"


def git(*args: str) -> str:
    return subprocess.check_output(["git", "-C", str(KSU), *args], text=True).strip()


def replace_block(path: Path, lines: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    block = START + "\n" + "\n".join(lines) + "\n" + END
    pattern = re.compile(re.escape(START) + r".*?" + re.escape(END), re.S)
    if not pattern.search(text):
        raise SystemExit(f"missing ReSukiSU auto block in {path.name}")
    path.write_text(pattern.sub(block, text, count=1), encoding="utf-8")


sha = git("rev-parse", "HEAD")
short = git("rev-parse", "--short=8", "HEAD")
tag = git("describe", "--tags", "--abbrev=0")
count = int(git("rev-list", "--count", "HEAD"))
code = 30700 + count
url = f"https://github.com/ReSukiSU/ReSukiSU/commit/{sha}"

replace_block(ROOT / "README.md", [
    f"- ReSukiSU `{tag}`",
    f"- ReSukiSU kernel version code `{code}`",
    f"- ReSukiSU commit [`{short}`]({url})",
])
replace_block(ROOT / "README_KO.md", [
    f"- ReSukiSU `{tag}`",
    f"- ReSukiSU 커널 버전 코드 `{code}`",
    f"- ReSukiSU 커밋 [`{short}`]({url})",
])

print(f"ReSukiSU README metadata: {tag} / {code} / {short}")
