require "test/unit"

require_relative "../src/eternalize_urls"

# These are a set of long-running integration tests
class IntegrationTest < Test::Unit::TestCase
  def file_does_not_exist
    result = archive_file('test/DOES_NOT_EXIST')
    assert_nil(result)
  end

  def test_empty
    result = archive_file('test/rsrc_empty.txt')
    assert_equal('', result)
  end

  def test_integration_test
    result = archive_file('test/rsrc_google_url.txt')
    archived = !result.nil? && (result.include?('archive.org') && result.include?('google.com'))
    assert_equal(true, archived)
  end

  def test_integration_test_complex_file
    result = archive_file('test/rsrc_complex_integration.tex')

    assert_false(result.nil?)
    assert_true(result.include?('archive.org') && result.include?('google.de'))
    assert_true(result.include?('http://doesnotexistaifjdoasfjfsd.com'))
    assert_true(result.include?('\ahref{'))
    assert_equal(5, result.scan(/archive.org/).length)
  end

  def test_integration_test_different_existing_mixed_urls
    result = archive_file('test/rsrc_different_existing_mixed_urls.txt')
    assert_equal(2, result.scan(/archive.org/).length)
  end

  def test_integration_test_same_existing_mixed_urls
    result = archive_file('test/rsrc_same_existing_mixed_urls.txt')
    assert_equal(2, result.scan(/archive.org/).length)
  end

  def test_integration_test_same_existing_mixed_urls_tex
    result = archive_file('test/rsrc_same_existing_mixed_urls.tex')
    assert_equal(3, result.scan(/archive.org/).length)
  end

  def test_transfer_embedded_urls
    result = archive_file('test/rsrc_transfer_embedded_urls.tex')
    assert_equal(2, result.scan(/archive.org/).length)
    assert_equal(0, result.scan(/\\url/).length)
    assert_equal(0, result.scan(/\\href/).length)
  end

  def test_urls_newlines
    result = archive_file('test/rsrc_urls_newlines.txt')
    assert_equal(3, result.scan(/archive.org/).length)
  end
end