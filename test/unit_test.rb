require "test/unit"

require_relative "../src/eternalize_urls"

class UnitTests < Test::Unit::TestCase
  def test_archive_urls_google
    assert_includes(archive_urls({'http://www.google.com'=>'http://url0.replace'}).values[0], 'web.archive.org/web/')
  end

  def test_archive_blocked_but_available_url
    assert_not_nil(archive_urls({'https://archive.org/web/'=>'http://url0.replace'}))
  end

  def test_archive_pure
    assert_nil(archive_urls({'https://pure.tudelft.nl/portal/files/38319277/TSE2776152.pdf'=>'http://url0.replace'}))
  end

  def test_extract_urls_from_file
    @content = 'http://www.google.de\n http://google.com http://www.google.de'
    urls = extract_urls_from_file
    expected_urls = {"http://www.google.de"=>"http://url0.replace", "http://google.com"=>"http://url1.replace"}
    expected_content = 'http://url0.replace\n http://url1.replace http://url0.replace'

    assert_equal(expected_urls, urls)
    assert_equal(expected_content, @content)
  end

  def test_not_working_url
    @content = 'goo.gl/baE8Q4'
  end

end

