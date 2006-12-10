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
end
