import re
from pathlib import Path
from urllib.parse import urlparse
for p in sorted(Path('_posts').glob('*.html')):
    t=p.read_text(encoding='utf-8',errors='ignore')
    urls=set(re.findall(r'https?://[^\s\"\'<>]+',t))
    hosts={urlparse(u).hostname for u in urls if urlparse(u).hostname in {'www.trifod.com','blogger.googleusercontent.com'}}
    if hosts:
        print(p.name, sorted(hosts), len([u for u in urls if urlparse(u).hostname in hosts]))
