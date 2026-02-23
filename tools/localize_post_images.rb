#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'digest'
require 'open-uri'
require 'nokogiri'
require 'uri'

ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(ROOT, '_posts')
MEDIA_ROOT = File.join(ROOT, 'assets', 'img', 'posts')
ALLOWED_HOSTS = %w[blogger.googleusercontent.com www.trifod.com trifod.com].freeze
IMAGE_EXT = %w[.jpg .jpeg .png .webp .gif .bmp].freeze

only_slug = ARGV[0]

FileUtils.mkdir_p(MEDIA_ROOT)
url_cache = {}
failed = {}
downloaded = 0
rewritten = 0

post_files = Dir.glob(File.join(POSTS_DIR, '*.html')).sort
if only_slug && !only_slug.strip.empty?
  post_files.select! { |p| File.basename(p, '.html').include?(only_slug) }
end

post_files.each do |post_path|
  doc = Nokogiri::HTML::DocumentFragment.parse(File.read(post_path, encoding: 'UTF-8'))
  post_slug = File.basename(post_path, '.html').sub(/^\d{4}-\d{2}-\d{2}-/, '')
  post_media_dir = File.join(MEDIA_ROOT, post_slug)
  FileUtils.mkdir_p(post_media_dir)
  changed = false

  doc.css('img,a').each do |node|
    attr = node.name == 'img' ? 'src' : 'href'
    raw = node[attr]
    next if raw.nil? || raw.strip.empty?
    next unless raw.start_with?('http://', 'https://')

    begin
      uri = URI.parse(raw)
    rescue URI::InvalidURIError
      next
    end

    next unless ALLOWED_HOSTS.include?(uri.host)
    ext = File.extname(uri.path).downcase
    next unless IMAGE_EXT.include?(ext) || (uri.host == 'blogger.googleusercontent.com' && uri.path.include?('/img/'))

    local_rel = url_cache[raw]
    unless local_rel
      ext = '.jpg' if ext.empty?
      filename = "#{Digest::SHA1.hexdigest(raw)[0, 16]}#{ext}"
      local_abs = File.join(post_media_dir, filename)
      local_rel = "/assets/img/posts/#{post_slug}/#{filename}"

      unless File.exist?(local_abs)
        begin
          data = URI.open(raw, 'rb', open_timeout: 3, read_timeout: 3, 'User-Agent' => 'Mozilla/5.0') { |io| io.read }
          next if data.nil? || data.empty?
          File.binwrite(local_abs, data)
          downloaded += 1
        rescue StandardError => e
          failed[raw] = e.class.name
          next
        end
      end

      url_cache[raw] = local_rel
    end

    node[attr] = local_rel
    rewritten += 1
    changed = true
  end

  File.write(post_path, doc.to_html, mode: 'w:utf-8') if changed
end

puts "Posts processed: #{post_files.length}"
puts "Downloaded files: #{downloaded}"
puts "Rewritten links: #{rewritten}"
puts "Failed URLs: #{failed.size}"
failed.first(15).each { |u,e| puts "- #{e}: #{u}" }
