require 'json'
require 'open-uri'

feed = JSON.parse(URI.open('https://jrduvvuri.blogspot.com/feeds/posts/default?alt=json&max-results=500', &:read))
entries = feed.dig('feed','entry') || []

slugs = {
  'long-ride-4-hyderabad-to-ooty-bike-ride' => '2021-12-07-long-ride-4-hyderabad-to-ooty-bike-ride.html',
  'hyderabad-to-varanasi-bike-ride' => '2022-12-25-hyderabad-to-varanasi-bike-ride.html',
  'long-ride-7-hyderabad-nepal-round-trip' => '2023-12-26-long-ride-7-hyderabad-nepal-round-trip.html',
  'long-ride-8-hyderabad-sikkim-round-trip' => '2025-01-26-long-ride-8-hyderabad-sikkim-round-trip.html'
}

entries.each do |e|
  alt = (e['link'] || []).find { |x| x['rel'] == 'alternate' }&.dig('href').to_s
  next if alt.empty?
  slugs.each do |slug, filename|
    next unless alt.include?("/#{slug}.html")

    title = e.dig('title','$t').to_s.gsub("'", "''")
    date = e.dig('published','$t').to_s.sub(/\.\d+/, '')
    body = e.dig('content','$t').to_s

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

    File.write("D:/jr-blog/_posts/#{filename}", out, mode: 'w:utf-8')
    puts "restored #{filename}"
  end
end
