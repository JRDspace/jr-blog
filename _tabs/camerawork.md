---
title: Blog Photos
layout: page
permalink: /camerawork/
icon: fas fa-camera
order: 1
---

A visual collection of photos from my blog posts.

<div class="camerawork-grid" id="camerawork-grid">
{% assign excluded = '/assets/img/posts/a-heartfelt-tribute-to-sunitha/8f8de40eb35cc087.jpg|/assets/img/posts/a-heartfelt-tribute-to-sunitha/943f5df15c2fd1c2.jpg|/assets/img/posts/dear-comrades/106b5a2b1d40f1fb.jpg|/assets/img/posts/dear-comrades/490c235ac7ad58a1.jpg|/assets/img/posts/dear-comrades/789e3ffdc7c4ec94.jpg|/assets/img/posts/dear-comrades/b38b248544405217.jpg|/assets/img/posts/dear-comrades/b933b97f791caf5a.jpg|/assets/img/posts/dear-comrades/c3688a1c42c3e641.jpg|/assets/img/posts/my-tears-srikanth-bolla/acf35158b48276a5.jpg|/assets/img/posts/my-tears-srikanth-bolla/9dcf34e7987207c2.jpg|/assets/img/posts/long-ride-8-hyderabad-sikkim-round-trip/eb8283f18cfff6a8.jpg|/assets/img/posts/long-ride-8-hyderabad-sikkim-round-trip/e8dd33ae65e926df.jpg' | split: '|' %}
{% assign all_media = site.static_files | where_exp: "file", "file.path contains '/assets/img/posts/'" %}
{% assign seen = '|' %}
{% for photo in all_media %}
  {% assign ext = photo.extname | downcase %}
  {% if ext == '.jpg' or ext == '.jpeg' or ext == '.png' or ext == '.webp' %}
    {% unless excluded contains photo.path %}
      {% capture marker %}|{{ photo.path }}|{% endcapture %}
      {% unless seen contains marker %}
  <figure class="camerawork-item">
    <img
      src="{{ photo.path }}"
      alt="{{ photo.basename | replace: '-', ' ' }}"
      loading="lazy"
      decoding="async"
      onerror="this.closest('figure').style.display='none'"
    >
  </figure>
        {% assign seen = seen | append: photo.path | append: '|' %}
      {% endunless %}
    {% endunless %}
  {% endif %}
{% endfor %}
</div>

