import concurrent.futures as cf
import hashlib
import re
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

ROOT = Path(r"D:\jr-blog")
POSTS = [
    ROOT / "_posts" / "2022-12-25-hyderabad-to-varanasi-bike-ride.html",
    ROOT / "_posts" / "2023-12-26-long-ride-7-hyderabad-nepal-round-trip.html",
    ROOT / "_posts" / "2025-01-26-long-ride-8-hyderabad-sikkim-round-trip.html",
]


def slug_from_post(p: Path) -> str:
    return p.stem.split('-', 3)[3]


def urls_from_content(content: str):
    return sorted(set(re.findall(r'https?://[^\s\"\'<>]+', content)))


def dl(url: str, path: Path):
    if path.exists() and path.stat().st_size > 0:
        return True
    req = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    for _ in range(3):
        try:
            with urlopen(req, timeout=12) as r:
                data = r.read()
            if data:
                path.write_bytes(data)
                return True
        except Exception:
            pass
    return False

for post in POSTS:
    content = post.read_text(encoding='utf-8', errors='ignore')
    slug = slug_from_post(post)
    media_dir = ROOT / 'assets' / 'img' / 'posts' / slug
    media_dir.mkdir(parents=True, exist_ok=True)

    urls = [u for u in urls_from_content(content) if urlparse(u).hostname == 'blogger.googleusercontent.com']

    mapping = {}
    jobs = []
    for u in urls:
        path = urlparse(u).path
        ext = Path(path).suffix.lower() or '.jpg'
        name = hashlib.sha1(u.encode('utf-8')).hexdigest()[:16] + ext
        abs_path = media_dir / name
        rel = f"/assets/img/posts/{slug}/{name}"
        mapping[u] = rel
        jobs.append((u, abs_path))

    failed = set()
    with cf.ThreadPoolExecutor(max_workers=12) as ex:
        futs = {ex.submit(dl, u, p): u for u, p in jobs}
        for fut in cf.as_completed(futs):
            if not fut.result():
                failed.add(futs[fut])

    for u in failed:
        mapping.pop(u, None)

    rewritten = 0
    for u, rel in mapping.items():
        if u in content:
            content = content.replace(u, rel)
            rewritten += 1

    post.write_text(content, encoding='utf-8')
    print(f"{post.name}: total={len(urls)} rewritten={rewritten} failed={len(failed)}")
