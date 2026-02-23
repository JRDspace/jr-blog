---
title: Blog Photos
layout: page
permalink: /camerawork/
icon: fas fa-camera
order: 1
---

A visual collection of photos from my blog posts.

<div class="camerawork-grid" id="camerawork-grid">
{% assign all_media = site.static_files | where_exp: "file", "file.path contains '/assets/img/posts/'" %}
{% for photo in all_media %}
  {% assign ext = photo.extname | downcase %}
  {% if ext == '.jpg' or ext == '.jpeg' or ext == '.png' or ext == '.webp' %}
  <figure class="camerawork-item">
    <a
      href="{{ photo.path | relative_url }}"
      class="camerawork-link"
      data-index="{{ forloop.index0 }}"
      aria-label="Open photo"
    >
      <img
        src="{{ photo.path | relative_url }}"
        alt="{{ photo.basename | replace: '-', ' ' }}"
        loading="lazy"
        decoding="async"
        onerror="this.closest('figure').style.display='none'"
      >
    </a>
  </figure>
  {% endif %}
{% endfor %}
</div>

<div class="camerawork-lightbox" id="camerawork-lightbox" hidden>
  <button class="camerawork-close" id="camerawork-close" aria-label="Close">&times;</button>
  <button class="camerawork-nav prev" id="camerawork-prev" aria-label="Previous">&#10094;</button>
  <img id="camerawork-full" alt="Photo preview">
  <button class="camerawork-nav next" id="camerawork-next" aria-label="Next">&#10095;</button>
</div>

<script>
(() => {
  const links = Array.from(document.querySelectorAll('.camerawork-link'));
  const lightbox = document.getElementById('camerawork-lightbox');
  const full = document.getElementById('camerawork-full');
  const closeBtn = document.getElementById('camerawork-close');
  const prevBtn = document.getElementById('camerawork-prev');
  const nextBtn = document.getElementById('camerawork-next');

  if (!links.length || !lightbox || !full) return;

  let current = 0;

  const openAt = (index) => {
    current = (index + links.length) % links.length;
    const link = links[current];
    full.src = link.href;
    full.alt = link.querySelector('img')?.alt || 'Photo';
    lightbox.hidden = false;
    document.body.style.overflow = 'hidden';
  };

  const close = () => {
    lightbox.hidden = true;
    full.src = '';
    document.body.style.overflow = '';
  };

  links.forEach((link, i) => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      openAt(i);
    });
  });

  prevBtn?.addEventListener('click', (e) => {
    e.stopPropagation();
    openAt(current - 1);
  });

  nextBtn?.addEventListener('click', (e) => {
    e.stopPropagation();
    openAt(current + 1);
  });

  closeBtn?.addEventListener('click', close);

  lightbox.addEventListener('click', (e) => {
    if (e.target === lightbox) close();
  });

  document.addEventListener('keydown', (e) => {
    if (lightbox.hidden) return;
    if (e.key === 'Escape') close();
    if (e.key === 'ArrowLeft') openAt(current - 1);
    if (e.key === 'ArrowRight') openAt(current + 1);
  });
})();
</script>