from pathlib import Path

targets = [
    Path('_posts/2021-12-07-long-ride-4-hyderabad-to-ooty-bike-ride.html'),
    Path('_posts/2021-12-28-trip-5-hyderabad-to-munnar-bike-ride.html'),
    Path('_posts/2022-12-25-hyderabad-to-varanasi-bike-ride.html'),
]

notice = (
    '<p><em>Note: Some images in this post are temporarily unavailable. '
    'I lost part of this media during migration, I am trying to retrieve it and will update this blog soon.</em></p>\n\n'
)

for p in targets:
    text = p.read_text(encoding='utf-8', errors='ignore')
    if 'I lost part of this media during migration' in text:
        print(f'skip {p.name}')
        continue

    marker = '---\n\n'
    idx = text.find(marker)
    if idx == -1:
        print(f'no frontmatter marker in {p.name}')
        continue

    insert_at = idx + len(marker)
    text = text[:insert_at] + notice + text[insert_at:]
    p.write_text(text, encoding='utf-8')
    print(f'updated {p.name}')
