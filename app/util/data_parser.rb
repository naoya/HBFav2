class DataParser
  def self.parse(url)
    error_ptr = Pointer.new(:object)

    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
    data = NSData.alloc.initWithContentsOfURL(NSURL.URLWithString(url), options:NSDataReadingUncached, error:error_ptr)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false

    unless data
      raise error_ptr[0]
    end
    data
  end
end
