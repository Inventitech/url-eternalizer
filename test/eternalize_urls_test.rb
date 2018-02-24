require "test/unit"

require_relative "../src/eternalize_urls"

class ThingsTest < Test::Unit::TestCase

  def setup
    # Set up some test conditions here
    # This will be invoked before each test
  end

  def teardown
    # This will be invoked after each test
    # Use to close connections, etc.
  end

  def test_eternalize_google
    assert_not_nil(archive_urls(['http://www.google.com']))
  end

  def test_integration_test
    result = archive_file('test/google_url.txt')
    archived = !result.nil? && (result.include?('archive.org') && result.include?('google.com'))
    assert_equal(true, archived)
  end
end