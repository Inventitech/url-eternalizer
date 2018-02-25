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

def extract_urls_from_file
  urls = {}
  i = 0
  extract_urls @content do |url|
    next if url.include? 'archive.org'
    replace_url = urls[url]
    if replace_url.nil?
      replace_url = "http://url#{i}.replace"
      urls[url] = replace_url
      i += 1
    end
    @content.sub! url, replace_url
  end

  urls
rescue => e
  STDERR.puts e
end

def reinsert_urls(urls_to_placeholder, archived_urls, is_latex)
  urls_to_placeholder.keys.each do |url|
    archived_urls[url].nil? ? replace_url = url : replace_url = archived_urls[url]

    if is_latex && !archived_urls[url].nil?
      replace_url = "\\ahref{#{archived_urls[url]}}{#{url}}"
      @content.gsub! /(\\url{#{urls_to_placeholder[url]}})/, replace_url
      @content.gsub! /(\\href{#{urls_to_placeholder[url]}})/, replace_url
      @content.gsub! /#{urls_to_placeholder[url]}/, replace_url
    else
      @content.gsub! /#{urls_to_placeholder[url]}/, replace_url
    end
  end
end

def extract_latest_version_api(uri_to_archive)
  wb = Wayback.page(uri_to_archive, :latest)
  wb.id
rescue => e
  STDERR.puts "Error (Could not retrieve) when archiving: #{uri_to_archive}"
  return nil
end

def archive_urls(urls_to_placeholder)
  return {} if urls_to_placeholder.nil? || urls_to_placeholder.empty?

  urls_to_archived_url = {}
  WaybackArchiver.archive(urls_to_placeholder.keys.flatten.to_a, strategy: :urls) do |result|
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
  begin
    @content = File.read(file)
  rescue => e
    STDERR.puts 'Could not read file'
  end
  return @content if @content.nil? || @content.empty?

  is_latex = file.end_with? '.tex'
  ahrefs = remove_and_replace_ahrefs if is_latex
  urls_to_placeholder = extract_urls_from_file
  urls_to_archived_urls = archive_urls(urls_to_placeholder)
  reinsert_urls urls_to_placeholder, urls_to_archived_urls, is_latex

  reinsert_ahrefs ahrefs if is_latex

  STDERR.puts 'Add this to your .tex: \newcommand{\ahref}[2]{\href{#1}{\nolinkurl{#2}}}' if is_latex
  @content
end
