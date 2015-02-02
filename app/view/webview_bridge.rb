module HBFav2
  class WebViewBridge < if UIDevice.currentDevice.ios8_or_later?
                          WKWebView
                        else
                          UIWebView
                        end

    def self.factory(frame)
      if kind_of?(WKWebView)
        self.alloc.initWithFrame(frame, configration:nil)
      else
        self.alloc.initWithFrame(frame)
      end
    end

    def title
      if kind_of?(WKWebView)
        super
      else
        stringByEvaluatingJavaScriptFromString("document.title")
      end
    end

    def URL
      if kind_of?(WKWebView)
        super
      else
        self.request.URL
      end
    end

    def delegate=(object)
      if kind_of?(WKWebView)
        self.navigationDelegate = object
        self.UIDelegate = object
      else
        super(object)
      end
    end

    def scalesPageToFit=(bool)
      unless kind_of?(WKWebView)
        super.scalesPageToFit(bool)
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
