module HBFav2
  class WebViewBridge < if UIDevice.currentDevice.ios8_or_later?
                          WKWebView
                        else
                          UIWebView
                        end

    def self.factory(frame)
      if kind_of?(UIWebView)
        self.alloc.initWithFrame(frame)
      else
        self.alloc.initWithFrame(frame, configration:nil)
      end
    end

    def title
      if kind_of?(UIWebView)
        stringByEvaluatingJavaScriptFromString("document.title")        
      else
        super
      end
    end

    def URL
      if kind_of?(UIWebView)
        self.request.URL
      else
        super        
      end
    end

    def delegate=(object)
      if kind_of?(UIWebView)
        super(object)
      else
        self.navigationDelegate = object
        self.UIDelegate = object
      end
    end

    def scalesPageToFit=(bool)
      if kind_of?(UIWebView)
        super.setScalesPageToFit(bool)
      end
    end

    def stopLoading
      super
      App.shared.networkActivityIndicatorVisible = false
    end

    def dealloc
      if self.loading?
        self.stopLoading
      end
      self.delegate = nil
      super
    end
  end
end
