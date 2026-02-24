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
    <img
      src="{{ photo.path }}"
      alt="{{ photo.basename | replace: '-', ' ' }}"
      loading="lazy"
      decoding="async"
      onerror="this.closest('figure').style.display='none'"
    >
  </figure>
  {% endif %}
{% endfor %}
</div>
