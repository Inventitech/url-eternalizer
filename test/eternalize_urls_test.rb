require "test/unit"

require_relative "../src/eternalize_urls"

class UnitTests < Test::Unit::TestCase
  def test_eternalize_google
    assert_not_nil(archive_urls(['http://www.google.com']))
  end

  def test_blocked_but_available_url
    assert_not_nil(archive_urls(['https://archive.org/web/']))
  end
end