require 'json'
require 'open-uri'
require 'nokogiri'

feed = JSON.parse(URI.open('https://jrduvvuri.blogspot.com/feeds/posts/default?alt=json&max-results=500', &:read))
entry = (feed.dig('feed','entry') || []).find do |e|
  alt = (e['link'] || []).find { |x| x['rel'] == 'alternate' }&.dig('href').to_s
  alt.include?('/2021/12/trip-5-hyderabad-to-munnar-bike-ride.html')
end
abort('not found') unless entry

alt = (entry['link'] || []).find { |x| x['rel'] == 'alternate' }&.dig('href').to_s
title = entry.dig('title','$t').to_s.gsub("'", "''")
date = entry.dig('published','$t').to_s.sub(/\.\d+/, '')
html = entry.dig('content','$t').to_s

doc = Nokogiri::HTML::DocumentFragment.parse(html)
# unwrap noisy inline wrappers that can break layout
%w[span font].each do |sel|
  doc.css(sel).each { |n| n.replace(n.children) }
end
# remove inline styles/classes from imported forum markup
doc.css('*').each do |n|
  n.remove_attribute('style')
  n.remove_attribute('class')
  n.remove_attribute('data-ipslightbox')
  n.remove_attribute('data-ipslightbox-group')
  n.remove_attribute('data-fileid')
  n.remove_attribute('data-fileext')
  n.remove_attribute('data-fullurl')
  n.remove_attribute('data-src')
  n.remove_attribute('data-ratio')
  n.remove_attribute('data-loaded')
  n.remove_attribute('rel') if n['rel'].to_s.empty?
end

body = doc.to_html
out = <<~TXT
---
title: '#{title}'
date: #{date}
author: Janaki Rajesh Duvvuri
categories: [Blogger]
tags: [migrated]
legacy_url: '#{alt}'
---

#{body}
TXT
File.write('D:/jr-blog/_posts/2021-12-28-trip-5-hyderabad-to-munnar-bike-ride.html', out, mode: 'w:utf-8')
puts 'cleaned munnar post structure'
