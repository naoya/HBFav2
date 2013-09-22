class NSURL
  def request
    NSURLRequest.alloc.initWithURL(self)
  end
end
