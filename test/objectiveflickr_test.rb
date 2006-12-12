require File.dirname(__FILE__) + '/test_helper.rb'

class ObjectiveFlickrTest < Test::Unit::TestCase

  def setup
  end
  
  def test_truth
    assert true
  end
  
  # we use a unit test API key for this purpose
  def test_echo
    f = FlickrInvocation.new('bf67a649fffb210651334a09b92df02e')
    r = f.call("flickr.test.echo")
    assert(r.ok?, "response should be ok")
    assert_equal(r["method"]["_content"], "flickr.test.echo", "method name should echo")
  end
  
  def test_default_settings
    FlickrInvocation.default_api_key 'bf67a649fffb210651334a09b92df02e'
    f = FlickrInvocation.new

    r = f.call("flickr.test.echo")
    assert(r.ok?, "response should be ok")
    assert_equal(r["method"]["_content"], "flickr.test.echo", "method name should echo")
  end
  
  def test_corrupt_key
    # try a corrupt key
    FlickrInvocation.default_api_key 'bf67a649fffb210651334a09b92df02f'
    FlickrInvocation.default_options :raise_exception_on_error => true

    f = FlickrInvocation.new
    r = f.call("flickr.test.echo")

  rescue => e
    assert(e.message.error?, "response should be an error")
    assert_equal(e.message.error_message, "Invalid API Key (Key not found)", "error message should be 'invalid API key'")
  end
end
