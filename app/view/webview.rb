module HBFav2
  class WebView < UIWebView
    def dealloc
      NSLog("dealloc: " + self.class.name)
      super
    end
  end
end
