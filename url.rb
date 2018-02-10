require 'net/http'
require 'uri'
require 'wayback'

# Possible alternatives for the future would be Perma.cc and Archive.is
@archive_url_base = 'https://web.archive.org'
@archive_url_part_save = '/save/'
@archive_url_part_web = '/web/'

def do_archive_url(uri_to_archive)
  uri = URI.parse(@archive_url_base + @archive_url_part_save + uri_to_archive)
  http = Net::HTTP.new uri.host
  resp = http.get("#{uri}")

  if resp.kind_of? Net::HTTPSuccess or resp.kind_of? Net::HTTPRedirection
    return extract_saved_url(resp.body)
  end

  return nil
rescue => e
  puts e.backtrace
  return nil
end

def extract_saved_url(html)
  extracted_url = html.scan( /var redirUrl = "(.*)";/).first.first
  @archive_url_base + extracted_url
end

def extract_latest_version_api(uri_to_archive)
  wb = Wayback.page(uri_to_archive, :latest)
  date = wb.id.scan(/(\d{14,14})/).first.first
  date
rescue => e
  puts e.backtrace
  return nil
end

def archive_url(uri_to_archive)
  puts "Archiving #{uri_to_archive} ..."
  begin
    # Ensure this is a valid URI at all
    uri = URI.parse(uri_to_archive)
  rescue URI::InvalidURIError => e
    puts e
    puts "#{uri_to_archive} is not a valid URL!"
    return
  end

  archived_url = do_archive_url(uri_to_archive)
  archived_latest_time = extract_latest_version_api(uri_to_archive)

  if archived_url.nil? and archived_latest_time.nil?
    archived_url = nil
    puts "Sorry, archiving #{uri_to_archive} did not work."
  elsif archived_url.nil?
    archived_url = @archive_url_base + @archive_url_part_web + archived_latest_time + '/' + uri_to_archive
    puts "Archiving #{uri_to_archive} likely did not work. The best we could do was #{archived_url}"
  elsif archived_url.include? (archived_latest_time.to_s)
    puts "Congratulations, the save operation for #{uri_to_archive} to #{archived_url} worked!"
  else
    puts "Congratulations, the save operation for #{uri_to_archive} to #{archived_url} worked!"
  end

  return archived_url
end

page = archive_url('http://google.com')