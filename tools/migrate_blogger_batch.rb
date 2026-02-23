#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'time'
require 'cgi'
require 'nokogiri'

BLOG_FEED = 'https://jrduvvuri.blogspot.com/feeds/posts/default?alt=json&max-results=500'
AUTHOR = 'Janaki Rajesh Duvvuri'
ALLOWED_ATTRS = %w[href src alt title width height allowfullscreen frameborder].freeze


def slugify(text)
  slug = text.to_s.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
  slug.empty? ? 'post' : slug
end


def unwrap!(doc, selector)
  doc.css(selector).each { |node| node.replace(node.children) }
end


def repair_mojibake(str)
  s = str.to_s.dup
  s.gsub!('Â ', ' ')
  s.gsub!('â€™', "'")
  s.gsub!('â€“', '-')
  s.gsub!('â€”', '--')
  s.gsub!('â€¦', '...')
  s
end


def decode_embedded_markup!(doc)
  doc.traverse do |node|
    next unless node.text?

    raw = node.text
    next if raw.nil? || raw.strip.empty?

    unescaped = CGI.unescapeHTML(raw)
    unescaped = repair_mojibake(unescaped)
    next if unescaped == raw

    if unescaped.match?(/<[^>]+>/)
      fragment = Nokogiri::HTML::DocumentFragment.parse(unescaped)
      node.replace(fragment)
    else
      node.content = unescaped
    end
  end
end


def clean_html(html)
  fragment = Nokogiri::HTML::DocumentFragment.parse(repair_mojibake(html.to_s))

  decode_embedded_markup!(fragment)
  fragment.css('script,style').remove
  unwrap!(fragment, 'span,font')

  fragment.css('*').each do |node|
    node.attribute_nodes.each do |attr|
      node.remove_attribute(attr.name) unless ALLOWED_ATTRS.include?(attr.name.downcase)
    end
  end

  fragment.css('p,div').each do |node|
    next unless node.text.strip.empty? && node.css('img,iframe,video').empty?

    node.remove
  end

  out = fragment.to_html
  out.gsub!("\r\n", "\n")
  out.gsub!(/\n{3,}/, "\n\n")
  out.strip
end


def front_matter(title, published_at, legacy_url)
  safe_title = title.to_s.gsub("'", "''")
  <<~YAML
    ---
    title: '#{safe_title}'
    date: #{published_at.strftime('%Y-%m-%d %H:%M:%S %z')}
    author: #{AUTHOR}
    categories: [Blogger]
    tags: [migrated]
    legacy_url: '#{legacy_url}'
    ---

  YAML
end


def load_entries
  json = URI.open(BLOG_FEED, &:read)
  parsed = JSON.parse(json)
  entries = parsed.dig('feed', 'entry') || []
  entries.sort_by { |e| Time.parse(e.dig('published', '$t')) }
end


def write_entry(entry, posts_dir)
  title = entry.dig('title', '$t').to_s
  published = Time.parse(entry.dig('published', '$t'))
  alternate = (entry['link'] || []).find { |x| x['rel'] == 'alternate' }
  legacy_url = alternate&.dig('href').to_s

  slug = legacy_url[%r{/([^/]+)\.html$}, 1]
  slug = slugify(title) if slug.nil? || slug.empty?

  base = "#{published.strftime('%Y-%m-%d')}-#{slug}"
  html_path = File.join(posts_dir, "#{base}.html")
  md_path = File.join(posts_dir, "#{base}.md")

  body = clean_html(entry.dig('content', '$t'))
  content = front_matter(title, published, legacy_url) + body + "\n"

  File.write(html_path, content, mode: 'w:utf-8')
  File.delete(md_path) if File.exist?(md_path)

  File.basename(html_path)
end


def main
  count = (ARGV[0] || '5').to_i
  start = (ARGV[1] || '1').to_i
  count = 5 if count <= 0
  start = 1 if start <= 0

  repo_root = File.expand_path('..', __dir__)
  posts_dir = File.join(repo_root, '_posts')

  entries = load_entries
  batch = entries[(start - 1), count] || []

  if batch.empty?
    puts "No posts in requested range start=#{start} count=#{count}"
    return
  end

  created = batch.map { |entry| write_entry(entry, posts_dir) }
  puts "Updated #{created.length} posts:"
  created.each { |name| puts "- #{name}" }
end

main
