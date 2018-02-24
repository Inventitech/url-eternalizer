require 'rubygems'
require 'bundler/setup'

require 'twitter-text'
require 'wayback_archiver'
require 'wayback'
require 'set'

include Twitter::TwitterText::Extractor

@content = ''
@verbose = false

def extract_urls_from_file(file)
  urls = Set.new
  File.open(file, 'r') do |f|
    f.each_line do |line|
      extract_urls line do |url|
        urls.add url unless url.include? 'archive.org'
      end
      @content += line
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
  is_latex = file.end_with? ".tex"
  urls = extract_urls_from_file(file)
  archived_urls = archive_urls(urls)
  archived_urls.keys.each do |url|
    next if archived_urls[url].nil?
    if is_latex
        @content.gsub! url, "\\ahref{#{archived_urls[url]}}{#{url}}"
      else
        @content.gsub! url, archived_urls[url]
    end
  end

  STDERR.puts 'Add this to your .tex: \newcommand{\ahref}[2]{\href{#1}{\nolinkurl{#2}}}' if is_latex
  puts @content
end
