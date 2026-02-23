require 'json'
require 'open-uri'
require 'time'

feed = JSON.parse(URI.open('https://jrduvvuri.blogspot.com/feeds/posts/default?alt=json&max-results=500', &:read))
entry = (feed.dig('feed','entry') || []).find do |e|
  links = e['link'] || []
  alt = links.find { |x| x['rel'] == 'alternate' }
  alt && alt['href']&.include?('/2021/12/trip-5-hyderabad-to-munnar-bike-ride.html')
end

abort('Post not found in feed') unless entry

title = entry.dig('title','$t').to_s.gsub("'", "''")
published = Time.parse(entry.dig('published','$t')).strftime('%Y-%m-%d %H:%M:%S %z')
legacy = (entry['link'] || []).find { |x| x['rel'] == 'alternate' }&.dig('href').to_s
body = entry.dig('content','$t').to_s

content = <<~MD
---
title: '#{title}'
date: #{published}
author: Janaki Rajesh Duvvuri
categories: [Blogger]
tags: [migrated]
legacy_url: '#{legacy}'
---

#{body}
MD

path = 'D:/jr-blog/_posts/2021-12-28-trip-5-hyderabad-to-munnar-bike-ride.html'
File.write(path, content, mode: 'w:utf-8')
puts 'restored post from feed'
