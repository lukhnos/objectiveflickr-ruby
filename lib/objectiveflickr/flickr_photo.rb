# objectiveflickr is a minimalistic Flickr API library that uses REST-style calls 
# and receives JSON response blocks, resulting in very concise code. Named so in 
# order to echo another Flickr library of mine, under the same name, developed 
# for Objective-C.
#
# Author:: Lukhnos D. Liu (mailto:lukhnos@gmail.com)
# Copyright:: Copyright (c) 2006 Lukhnos D. Liu
# License:: Distributed under the New BSD License

# This helper module provides a set of utility methods for Flickr photos.
# Methods such as unique_id_from_hash and url_from_unique_id are 
# helpful when you try to move the photo id data to and fro your web 
# apps. 

module FlickrPhoto
  @photo_url_base = 'static.flickr.com'

  # Set the default photo base URL, without the http:// part
  def self.default_photo_url_base(b)
    @photo_url_base = b
  end

  # This utility method returns the URL of a Flickr photo using
  # the keys :farm, :server, :id, :secret, :size and :type  
  def self.url_from_hash(params)
    self.url_from_normalized_hash(self.normalize_parameter(params))
  end

  # This utility method combines the Flickr photo keys (from which
  # one gets the real URL of a photo) into a photo id that you can
  # use in a div
  def self.unique_id_from_hash(params, prefix='photo')
    p = self.normalize_parameter(params)
    [prefix, p[:server], p[:id], p[:secret], p[:farm], p[:size], p[:type]].join("-")    
  end

  # This utility method breaks apart the photo id into Flickr photo
  # keys and returns the photo URL  
  def self.url_from_unique_id(uid)
    self.url_from_normalized_hash(self.hash_from_unique_id(uid))
  end

  # This utility method breaks apart the photo id into Flickr photo
  # keys and returns a hash of the photo information
  #
  # NOTE: No sanitation check here
  def self.hash_from_unique_id(uid)      
    p = uid.split("-")
    {
      :server=>p[1], :id=>p[2], :secret=>p[3],
      :farm=>p[4], :size=>p[5], :type=>p[6]
    }
  end

  private
  def self.url_from_normalized_hash(p)
    urlbase = (p[:farm] && p[:farm].to_s.length > 0) ? "http://farm#{p[:farm]}." : "http://"
    url = "#{urlbase}#{@photo_url_base}/#{p[:server]}/#{p[:id]}_#{p[:secret]}"
    url += "_#{p[:size]}" if p[:size].length > 0
    url += ".#{p[:type]}"
  end

  private
  def self.normalize_parameter(params)
    {
      :farm => (params[:farm] || params["farm"] || "").to_s,
      :server => (params[:server] || params["server"] || "").to_s,
      :id => (params[:id] || params["id"] || "").to_s,
      :secret => (params[:secret] || params["secret"] || "").to_s,
      :size => (params[:size] || params["size"] || "").to_s,
      :type => (params[:type] || params["type"] || "jpg").to_s
    }
  end
end

