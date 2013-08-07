module HBFav2
  class WebView < UIWebView
    def stopLoading
      super
      App.shared.networkActivityIndicatorVisible = false
    end

    def dealloc
      NSLog("dealloc: " + self.class.name)
      super
    end
  end
end
