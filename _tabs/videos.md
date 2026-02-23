---
title: Videos
layout: page
permalink: /videos/
icon: fas fa-video
order: 2
---

Latest videos from my YouTube channel.

<div class="videos-grid" id="videos-grid">
  <p id="videos-loading">Loading videos...</p>
</div>

<p class="videos-channel-link">
  <a href="https://www.youtube.com/@Wheellogyt" target="_blank" rel="noopener noreferrer">Open YouTube Channel</a>
</p>

<script>
(() => {
  const grid = document.getElementById('videos-grid');
  const loading = document.getElementById('videos-loading');
  if (!grid) return;

  const DATA_URL = '/assets/data/wheellogyt-videos.json';

  const thumbCandidates = (id, first) => {
    const list = [];
    if (first) list.push(first);
    list.push(`https://i.ytimg.com/vi/${id}/hqdefault.jpg`);
    list.push(`https://img.youtube.com/vi/${id}/hqdefault.jpg`);
    list.push(`https://i.ytimg.com/vi/${id}/mqdefault.jpg`);
    list.push(`https://img.youtube.com/vi/${id}/mqdefault.jpg`);
    list.push(`https://i.ytimg.com/vi/${id}/default.jpg`);
    return [...new Set(list)];
  };

  fetch(DATA_URL)
    .then((r) => {
      if (!r.ok) throw new Error('Video data not found');
      return r.json();
    })
    .then((items) => {
      if (!Array.isArray(items) || !items.length) throw new Error('No videos');

      grid.innerHTML = '';

      items.forEach((item) => {
        if (!item.id) return;

        const id = item.id;
        const title = item.title || 'Untitled';
        const link = item.link || `https://www.youtube.com/watch?v=${id}`;

        const card = document.createElement('a');
        card.className = 'video-card';
        card.href = link;
        card.target = '_blank';
        card.rel = 'noopener noreferrer';

        const img = document.createElement('img');
        img.alt = title;
        img.loading = 'lazy';
        img.decoding = 'async';

        const candidates = thumbCandidates(id, item.thumbnail || '');
        let idx = 0;
        img.src = candidates[idx];
        img.onerror = () => {
          idx += 1;
          if (idx < candidates.length) {
            img.src = candidates[idx];
          } else {
            img.onerror = null;
            img.style.display = 'none';
          }
        };

        const h3 = document.createElement('h3');
        h3.textContent = title;

        card.appendChild(img);
        card.appendChild(h3);
        grid.appendChild(card);
      });

      if (!grid.children.length) {
        throw new Error('No renderable videos');
      }
    })
    .catch(() => {
      if (loading) {
        loading.textContent = 'Unable to load videos right now. Please open the channel link below.';
      }
    });
})();
</script>