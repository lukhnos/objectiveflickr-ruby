# objectiveflickr is a minimalistic Flickr API library that uses REST-style calls 
# and receives JSON response blocks, resulting in very concise code. Named so in 
# order to echo another Flickr library of mine, under the same name, developed 
# for Objective-C.
#
# Author:: Lukhnos D. Liu (mailto:lukhnos@gmail.com)
# Copyright:: Copyright (c) 2006 Lukhnos D. Liu
# License:: Distributed under the New BSD License

# This class plays the major role of the package. Named "FlickrInvocation"
# to allude to the making of an RPC call.

require 'rubygems'
require 'net/http'
require 'jcode'
require 'digest/md5'
$KCODE = 'UTF8'

# FlickrInvocation
class FlickrInvocation
  API_KEY = ''
  SHARED_SECRET = ''
  AUTH_ENDPOINT = 'http://flickr.com/services/auth/'
  REST_ENDPOINT = 'http://api.flickr.com/services/rest/'
  PHOTOURL_BASE = 'http://static.flickr.com/'

  # Initializes the instance with the api_key (required) and an 
  # optional shared_secret (required only if you need to make 
  # authenticated call). Current available option is:
  # * :exception_on_error: set this key to true if you want the
  #   call method to raise an error if Flickr returns one
  def initialize(api_key = nil, shared_secret = nil, options = {})
    @api_key = api_key || API_KEY
    @shared_secret = shared_secret || SHARED_SECRET
    
    # options
    @option_exception_on_error = options[:exception_on_error] ? true : false
  end
  
  # Invoke a Flickr method, pass :auth=>true in the param hash
  # if you want the method call to be signed (required when you
  # make authenticaed calls, e.g. flickr.auth.getFrob or 
  # any method call that requires an auth token)
  def call(method, params=nil)
    url = method_url(method, params)
    rsp = FlickrResponse.new Net::HTTP.get(URI.parse(url))
    
    if @option_exception_on_error && rsp.error?
      raise rsp.error_message
    end
    
    rsp
  end
  
  # Returns a login URL to which you can redirect user's browser
  # to complete the Flickr authentication process (Flickr then uses
  # the callback address you've set previously to pass the
  # authentication frob back to your web app)
  def login_url(permission)
    sig = api_sig(:api_key => @api_key, :perms => permission.to_s)
    url = "#{AUTH_ENDPOINT}?api_key=#{@api_key}&perms=#{permission}&api_sig=#{sig}"
  end
    
  # This utility method returns the URL of a Flickr photo using
  # the keys :server_id, :id, :secret, :size and :type
  def photo_url(params)
    photo_url_form(photo_params(params))
  end
  
  # This utility method combines the Flickr photo keys (from which
  # one gets the real URL of a photo) into a photo id that you can
  # use in a div
  def photo_div_id(params, prefix='photo')
    p = photo_params(params)
    [prefix, p[:server_id], p[:id], p[:secret], p[:size], p[:type]].join("-")
  end
  
  # This utility method breaks apart the photo id into Flickr photo
  # keys and returns the photo URL
  def photo_url_from_div_id(params)
    photo_url(photo_info_from_div_id(params))
  end

  # This utility method breaks apart the photo id into Flickr photo
  # keys and returns a hash of the photo information
  def photo_info_from_div_id(params)
    p = params.split("-")
    { :server_id=>p[1], :id=>p[2], :secret=>p[3], :size=>p[4], :type=>p[5] }
  end
  
  private
  def method_url(method, params=nil)
    p = params || {}
    
    p[:format] = 'json'
    p[:nojsoncallback] = 1
    
    url = "#{REST_ENDPOINT}?api_key=#{@api_key}&method=#{method}"
    if p[:auth] || p["auth"]
      p.delete(:auth)
      p.delete("auth")
      sigp = p
      sigp[:method] = method
      sigp[:api_key] = @api_key
      p["api_sig"] = api_sig(sigp)
    end
    
    p.keys.each { |k| url += "&#{k.to_s}=#{p[k]}" }
    url
  end
  
  private
  def photo_url_form(p)
    url = "#{PHOTOURL_BASE}#{p[:server_id]}/#{p[:id]}_#{p[:secret]}"
    if p[:size].length > 0
      url += "_#{p[:size]}"
    end

    url += ".#{p[:type]}"
  end

  private
  def photo_params(params)
    {
      :server_id => params[:server] || params["server"] || params[:server_id] || params["server_id"] || "",
      :id => params[:id] || params["id"] || "",
      :secret => params[:secret] || params["secret"] || "",
      :size => params[:size] || params["size"] || "",
      :type => params[:type] || params["type"] || "jpg"
    }
  end

  private
  def api_sig(params)
    sigstr = @shared_secret
    params.keys.sort { |x, y| x.to_s <=> y.to_s }.each { |k|
      sigstr += k.to_s
      sigstr += params[k].to_s
    }  
    md5str = Digest::MD5.hexdigest(sigstr)
    # print "sigstr=#{sigstr}, md5str=#{md5str}\n"
    md5str
  end
end