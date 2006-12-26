require File.dirname(__FILE__) + '/test_helper.rb'
require 'yaml'

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
  
  def test_deprecated_photo_helpers    
    f = FlickrInvocation.new
    params = {:server=>1234, :id=>5678, :secret=>90, :farm=>321}
    assert_equal(f.photo_url(params), "http://farm321.static.flickr.com/1234/5678_90.jpg", "URL helper failed")
    uid = f.photo_div_id(params)
    assert_equal(uid, "photo-1234-5678-90-321--jpg", "UID failed")
  end
  
  def test_photo_helpers
    params = {:server=>"1234", :id=>"5678", :secret=>"90" }
        
    assert_equal(FlickrPhoto.url_from_hash(params), "http://static.flickr.com/1234/5678_90.jpg", "URL helper failed")
    params[:farm] = "321"
    assert_equal(FlickrPhoto.url_from_hash(params), "http://farm321.static.flickr.com/1234/5678_90.jpg", "URL helper failed")
    params[:farm] = nil
    
    uid = FlickrPhoto.unique_id_from_hash(params, 'blah')
    assert_equal(uid, "blah-1234-5678-90---jpg", "UID failed")
    
    params[:farm] = "321"
    params[:size] = 'b'
    uid = FlickrPhoto.unique_id_from_hash(params, 'blah')
    assert_equal(uid, "blah-1234-5678-90-321-b-jpg", "UID failed")

    
    assert_equal(FlickrPhoto.url_from_unique_id(uid), "http://farm321.static.flickr.com/1234/5678_90_b.jpg", "URL helper failed")    
    
    params[:type] = 'jpg'
    h = FlickrPhoto.hash_from_unique_id(uid)
    assert_equal(h, params, "hash_from_unique_id failed")

  end 
  
  
end
