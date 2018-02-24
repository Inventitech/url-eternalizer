require "test/unit"

require_relative "../src/eternalize_urls"

# These are a set of long-running integration tests
class IntegrationTest < Test::Unit::TestCase
  def test_integration_test
    result = archive_file('test/google_url.txt')
    archived = !result.nil? && (result.include?('archive.org') && result.include?('google.com'))
    assert_equal(true, archived)
  end

  def test_integration_test_complex_file
    result = archive_file('test/complex_integration.tex')
    puts result

    assert_false(result.nil?)
    assert_true(result.include?('archive.org') && result.include?('google.de'))
    assert_true(result.include?('http://doesnotexistaifjdoasfjfsd.com'))
    assert_true(result.include?('\ahref{'))
    assert_equal(5, result.scan(/archive.org/).length)
  end
end