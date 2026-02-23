import concurrent.futures as cf
import hashlib
import re
import time
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

POST = Path(r"D:\jr-blog\_posts\2025-01-26-long-ride-8-hyderabad-sikkim-round-trip.html")
TRIFOD_POST = Path(r"D:\jr-blog\_posts\2021-12-28-trip-5-hyderabad-to-munnar-bike-ride.html")
ROOT = Path(r"D:\jr-blog")


def hash_name(url: str, ext: str) -> str:
    return f"{hashlib.sha1(url.encode('utf-8')).hexdigest()[:16]}{ext}"


def ext_from_url(url: str) -> str:
    p = urlparse(url).path
    ext = Path(p).suffix.lower()
    return ext if ext else ".jpg"


def collect_urls(content: str, host: str):
    urls = sorted(set(re.findall(r"https?://[^\s\"'<>]+", content)))
    out = []
    for u in urls:
        try:
            if urlparse(u).hostname == host:
                out.append(u)
        except Exception:
            pass
    return out


def download_one(url: str, out_path: Path):
    if out_path.exists() and out_path.stat().st_size > 0:
        return True, "exists"
    for _ in range(3):
        try:
            req = Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urlopen(req, timeout=12) as r:
                data = r.read()
            if data:
                out_path.write_bytes(data)
                return True, "downloaded"
        except Exception:
            pass
        time.sleep(0.5)
    return False, "failed"


def localize_post(post: Path, host: str, slug: str, workers: int):
    content = post.read_text(encoding="utf-8")
    urls = collect_urls(content, host)
    media_dir = ROOT / "assets" / "img" / "posts" / slug
    media_dir.mkdir(parents=True, exist_ok=True)

    mapping = {}
    jobs = []
    for u in urls:
        ext = ext_from_url(u)
        name = hash_name(u, ext)
        abs_path = media_dir / name
        mapping[u] = f"/assets/img/posts/{slug}/{name}"
        jobs.append((u, abs_path))

    failed_urls = set()
    downloaded = 0

    with cf.ThreadPoolExecutor(max_workers=workers) as ex:
        futs = {ex.submit(download_one, u, p): u for u, p in jobs}
        done = 0
        total = len(jobs)
        for fut in cf.as_completed(futs):
            done += 1
            ok, state = fut.result()
            u = futs[fut]
            if ok and state == "downloaded":
                downloaded += 1
            if not ok:
                failed_urls.add(u)
            if done % 25 == 0:
                print(f"progress {post.name}: {done}/{total}, downloaded={downloaded}, failed={len(failed_urls)}")

    for u in failed_urls:
        mapping.pop(u, None)

    rewritten = 0
    for u, rel in mapping.items():
        if u in content:
            content = content.replace(u, rel)
            rewritten += 1

    post.write_text(content, encoding="utf-8")
    print(f"DONE {post.name}: total={len(urls)} rewritten={rewritten} failed={len(failed_urls)} downloaded_new={downloaded}")


if __name__ == "__main__":
    localize_post(POST, "blogger.googleusercontent.com", "long-ride-8-hyderabad-sikkim-round-trip", workers=12)
    localize_post(TRIFOD_POST, "www.trifod.com", "trip-5-hyderabad-to-munnar-bike-ride", workers=2)
