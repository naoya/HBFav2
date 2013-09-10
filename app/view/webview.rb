module HBFav2
  class WebView < UIWebView
    def stopLoading
      super
      App.shared.networkActivityIndicatorVisible = false
    end

    def dealloc
      if self.loading?
        self.stopLoading
      end
      self.delegate = nil

      NSLog("dealloc: " + self.class.name)
      super
    end
  end
end
