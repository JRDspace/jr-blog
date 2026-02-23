require 'json'
require 'open-uri'

feed = JSON.parse(URI.open('https://jrduvvuri.blogspot.com/feeds/posts/default?alt=json&max-results=500', &:read))
entry = (feed.dig('feed','entry') || []).find do |e|
  alt = (e['link'] || []).find { |x| x['rel'] == 'alternate' }&.dig('href').to_s
  alt.include?('/2023/12/long-ride-7-hyderabad-nepal-round-trip.html')
end
abort('not found') unless entry
alt = (entry['link'] || []).find { |x| x['rel'] == 'alternate' }&.dig('href').to_s
title = entry.dig('title','$t').to_s.gsub("'", "''")
date = entry.dig('published','$t').to_s.sub(/\.\d+/, '')
body = entry.dig('content','$t').to_s
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
File.write('D:/jr-blog/_posts/2023-12-26-long-ride-7-hyderabad-nepal-round-trip.html', out, mode: 'w:utf-8')
puts 'restored nepal post'
