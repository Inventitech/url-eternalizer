require 'rubygems'
require 'bundler/setup'

require 'twitter-text'
require 'wayback_archiver'
require 'wayback'
require 'set'

include Twitter::TwitterText::Extractor

@content = ''
@verbose = false

def remove_and_replace_ahrefs
  ahrefs = @content.scan(/\\ahref{.+?}{.+?}/)
  i = 0
  ahrefs.each do |ahref|
    @content.sub! ahref, "\\ahref{#{i}}"
    i += 1
  end
  ahrefs
end

def reinsert_ahrefs(ahrefs)
  i = 0
  ahrefs.each do |ahref|
    @content.sub! "\\ahref{#{i}}", ahref
    i += 1
  end
end

def extract_urls_from_file(is_latex)
  urls = Set.new
  @content.each_line do |line|
    extract_urls line do |url|
      urls.add url unless url.include? 'archive.org'
    end
  end

  urls
rescue => e
  STDERR.puts e
end

def extract_latest_version_api(uri_to_archive)
  wb = Wayback.page(uri_to_archive, :latest)
  wb.id
rescue => e
  STDERR.puts e.backtrace
  return nil
end

def archive_urls(urls)
  urls_to_archived_url = {}
  WaybackArchiver.archive(urls.flatten.to_a, strategy: :urls) do |result|
    if result.success?
      archived_url = extract_latest_version_api(result.archived_url)
      next if archived_url.nil?

      STDERR.puts "Successfully archived: #{archived_url}" if @verbose
      urls_to_archived_url[result.archived_url] = archived_url
    else
      STDERR.puts "Error (HTTP #{result.code}) when archiving: #{result.archived_url}"
    end
  end

  urls_to_archived_url
end

def archive_file(file)
  @content = File.read(file)

  is_latex = file.end_with? '.tex'
  ahrefs = remove_and_replace_ahrefs if is_latex
  urls = extract_urls_from_file(is_latex)
  return @content if urls.empty?

  archived_urls = archive_urls(urls)
  archived_urls.keys.each do |url|
    next if archived_urls[url].nil?
    if is_latex
        @content.gsub! url, "\\ahref{#{archived_urls[url]}}{#{url}}"
      else
        @content.gsub! /^[^\/]*#{url}/, archived_urls[url]
    end
  end

  reinsert_ahrefs ahrefs if is_latex

  STDERR.puts 'Add this to your .tex: \newcommand{\ahref}[2]{\href{#1}{\nolinkurl{#2}}}' if is_latex
  @content
end
