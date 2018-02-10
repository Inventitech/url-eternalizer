# Perma.cc
# Archive.is
require 'net/http'
require 'uri'
require 'wayback'

@base_url = 'https://web.archive.org/save/'

def archive_url(uri_to_archive)
  uri = URI.parse(@base_url + uri_to_archive)
  http = Net::HTTP.new uri.host
  resp = http.get("#{uri.path}?#{uri.query.to_s}")

  if resp.kind_of? Net::HTTPSuccess or resp.kind_of? Net::HTTPRedirection
    puts resp.body
  end
end


page = archive_url('http://inventitech.com')